# shellcheck shell=sh
# Shared by every scaffold-<stack> skill. Each skill's scripts/scaffold sources this file.
# The source of truth is skills/scaffold/_shared/scripts/scaffold-lib.sh in kgrigorev/skills;
# scripts/sync-scaffold-shared copies it into every skill. Edit it there, never in a copy.
#
# Template rules: every file under template/ ends in ".tmpl", which is dropped, so the files stay
# inert inside the skill. {{name}} placeholders are replaced in paths and text. Only names set
# with set_var are replaced, so other braces, such as ${{ github.ref }} or {{0}}, stay as they are.
# The scaffold never overwrites a file: it checks every destination before it writes anything.

fail() {
  echo "scaffold: $1" >&2
  exit 1
}

# Checks the three inputs every stack takes.
# Usage: check_inputs <package> <synopsis> <reader>
check_inputs() {
  printf '%s' "$1" | grep -Eqx '[a-z][a-z0-9]*(-[a-z][a-z0-9]*)*' ||
    fail "package \"$1\": use lower-case words joined by \"-\", each starting with a letter."
  one_line synopsis "$2"
  one_line reader "$3"
}

# Checks that a text input is one non-empty line that the templates can hold.
# Usage: one_line <input name> <value>
one_line() {
  # shellcheck disable=SC1003 # '\' is one backslash: a pattern that matches it anywhere
  case $2 in
  '' | *'"'* | *'\'* | *'{{'* | *'`'*)
    fail "$1: give one line without double quotes, backslashes, backticks or \"{{\"." ;;
  esac
  [ "$(printf '%s\n' "$2" | wc -l)" -eq 1 ] || fail "$1: give one line."
}

# Fails unless every named command is on PATH.
# Usage: require_tools <tool>...
require_tools() {
  missing=''
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
  done
  [ -z "$missing" ] || fail "missing tools:$missing"
}

# Some installers skip hidden files. Without them the project has no CI, hooks or agent rules.
# Usage: require_hidden <template dir>
require_hidden() {
  for hidden in .gitignore.tmpl .github/workflows/ci.yml.tmpl .github/workflows/pr-title.yml.tmpl \
    .githooks/pre-push.tmpl .claude/settings.json.tmpl .claude/hooks/check-on-stop.sh.tmpl; do
    [ -f "$1/$hidden" ] ||
      fail "template/$hidden is missing. Reinstall the skill with its hidden files."
  done
}

scaffold_sed=$(mktemp "${TMPDIR:-/tmp}/scaffold-sed.XXXXXX") || fail 'cannot create a temporary file'
trap 'rm -f "$scaffold_sed"' EXIT

# Sets the value of a {{name}} placeholder.
# Usage: set_var <name> <value>
set_var() {
  printf '%s' "$1" | grep -Eqx '[a-z][a-z0-9_]*' || fail "bad placeholder name \"$1\""
  value=$(printf '%s' "$2" | sed 's/[\/&]/\\&/g')
  printf 's/{{%s}}/%s/g\n' "$1" "$value" >>"$scaffold_sed"
}

render() { sed -f "$scaffold_sed"; }

# src/{{module}}.hs.tmpl -> src/MyTool.hs
destination() { printf '%s\n' "$1" | sed 's/\.tmpl$//' | render; }

# Renders every template file into the target folder.
# Usage: render_template <template dir> <target dir>
render_template() {
  sources=$(cd "$1" && find . -type f -name '*.tmpl' | sed 's#^\./##' | sort)
  for source in $sources; do
    path=$2/$(destination "$source")
    [ ! -e "$path" ] || fail "$path exists. Nothing was written."
  done
  mkdir -p "$2"
  for source in $sources; do
    path=$2/$(destination "$source")
    mkdir -p "$(dirname "$path")"
    render <"$1/$source" >"$path"
  done
  rendered_files=$(for source in $sources; do destination "$source"; done)
}

# Run inside the target after render_template: sets the executable bits, rejects leftover
# placeholders, runs git init when needed and points git at the project's hooks. It reads and
# changes only the rendered files, so the files of an existing clone stay as they are.
finish_project() {
  for file in $rendered_files; do # template paths have no spaces
    case $file in
    # Set by path, because some installers drop the executable bits of the template files.
    scripts/* | .githooks/* | .claude/hooks/*) chmod +x "$file" ;;
    esac
  done
  # shellcheck disable=SC2086 # template paths have no spaces
  if grep -nE '\{\{[a-z][a-z0-9_]*\}\}' $rendered_files; then
    fail 'the lines above still hold a placeholder. Fix the template.'
  fi
  [ -e .git ] || git init --quiet --initial-branch=main
  git config core.hooksPath .githooks
}

# Prints the rendered file list.
list_files() { printf '%s\n' "$rendered_files"; }
