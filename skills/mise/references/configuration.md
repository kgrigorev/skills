# mise configuration

Checked against mise `2026.11.3`. Every key with its type and default:
<https://mise.jdx.dev/configuration/reference.html>. For keys in a file you have open,
`mise config explain [KEY]`.

## Config files and precedence

mise merges every config from the current directory up to the root, then global and system.
Closer directories win. Within one directory, highest first:

1. `mise.<env>.local.toml` (gitignore)
2. `mise.local.toml` (gitignore)
3. `mise.<env>.toml`, e.g. `mise.ci.toml` (commit)
4. `mise.toml` (commit), or the alternate locations `mise/config.toml`, `.mise/config.toml`,
   `.config/mise.toml`, `.config/mise/config.toml`
5. `conf.d/*.toml` fragments in those config dirs, alphabetical. A dot before `.toml` marks an
   environment fragment (`node.ci.toml` loads only under env `ci`), so name multi-word
   fragments with hyphens (`node-tools.toml`).

Then `~/.config/mise/config.toml` (global) and `/etc/mise/config.toml` (system). A global
`config.override.toml` sits above project config, for settings a project may not override.
`.tool-versions` is always read; idiomatic files (`.nvmrc`, `.python-version`, …) only for
tools in `idiomatic_version_file_enable_tools`.

Platform files load automatically: `mise.unix.toml` < `mise.<os>.toml` <
`mise.<os>-<arch>.toml` (e.g. `mise.macos-arm64.toml`).

`include = ["../shared/mise.toml", "git::…", "oci::…"]` merges a shared file beneath the one
that includes it.

**Merge:** `[tools]`, `[env]` and `[settings]` merge per key, closer file wins. A task of the
same name replaces the farther one whole.

Commit `mise.toml`, env files, `conf.d/`, `.tool-versions` and `mise.lock`. Gitignore
`mise.local.toml` and `mise.*.local.toml`.

## Sections of mise.toml

```toml
min_version = "2026.11.0"   # error on older mise; { soft = "…" } only warns

[tools]                     # versions; recipes in languages.md
[env]                       # env vars, dotenv, PATH
[tasks.test]                # see tasks-and-boundary.md
[settings]                  # ignored until the file is trusted
[tool_alias.node.versions]  # version aliases
[vars]                      # template variables: {{ vars.region }}
[hooks]                     # see Hooks
[_]                         # free-form metadata mise ignores
```

## `[tools]`

```toml
[tools]
go = "1.26"                                  # newest installed 1.26.x
node = "lts"
python = ["3.13", "3.12"]                    # several versions; first is default
ruff = "latest"                              # registry shorthand → backend chosen for you
"github:owner/repo" = "1.2.3"                # explicit backend
"go:example.com/tool" = { version = "latest", install_env = { GOPRIVATE = "example.com/*" } }
cmake = { version = "4", os = ["linux", "macos"] }
```

Version forms: exact (`1.26.3`), prefix (`1.26`, `24`), `latest`, `lts`, `ref:<git-ref>` on
source backends, aliases. `mise ls-remote <tool>` lists versions; `mise latest <tool>@24`
resolves one.

Common table options: `version`, `os`, `postinstall` (shell after install), `install_env`,
`depends`. Each backend has its own options, and an option the backend doesn't read fails the
install. Check with `mise config explain tools.<name>`.

## `[env]`

```toml
[env]
NODE_ENV = "development"
SECRET = { value = "…", redact = true }      # masked in task output
_.file = [".env", { path = ".env.local", redact = true }]  # dotenv, JSON, YAML, TOML
_.file = { path = [".env", ".env.local"], find_up = true }  # search parents (monorepo .env)
_.path = ["{{ config_root }}/node_modules/.bin", { path = ["~/bin"], position = "append" }]
_.source = "./scripts/env.sh"                # import exports from a script
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }  # needs tool paths resolved
```

- `_.` directives run in written order, so a `_.path` can use a var a `_.source` exported.
- `$VAR` and `${VAR}` expand in values (`env_shell_expand`, on by default). Values read from
  JSON/YAML/TOML env files stay literal unless the entry sets `expand = true`.
- `_.path` entries go ahead of tool paths; `position = "append"` puts them after tool paths
  and ahead of the inherited `PATH`.
- `redactions = ["*_TOKEN", "API_KEY"]` (top level) redacts by name or glob. Redaction filters
  task output, so `raw = true` tasks bypass it. `mise env --redacted` prints the redacted
  vars _unmasked_; keep its output out of logs and chat.
- `mise set KEY=val` / `mise unset KEY` write `[env]` for you; `mise set` lists values and
  their source files.

## Environments (`MISE_ENV`)

```bash
mise -E ci run test          # or MISE_ENV=ci; several: -E ci,test (later wins)
```

`MISE_ENV` decides which files load, so `mise.toml` can't set it. Set it in the shell, in CI,
or as `env = ["dev"]` in `.miserc.toml` (project) or `~/.miserc.toml` (global).

## Trust

Config can run code (hooks, `_.source`, templates with `exec()`, tasks, postinstall), so mise
loads it only once trusted.

- **No trust needed:** a file with no template syntax holding only `min_version`,
  plain-version `[tools]`, and `[tasks]` without `secrets`.
- **Everything else** needs trust. Untrusted, `mise ls`/`env`/`tasks`/`config` fail with
  "Config files in … are not trusted", and shell activation skips the file with a warning.
  `[settings]` from an untrusted file is ignored.
- **Implicit trust:** `mise run`, `mise <task>`, `mise exec`, `mise install`, `mise watch`
  and `mise tasks add` trust the active config and persist it. MCP calls, shims and
  `--help` do not.
- Trust covers the repo's git worktrees too. `mise trust --show` shows status;
  `mise untrust` revokes.
- **Safe mode** (`MISE_SAFE=1`): mise reads config inertly. No trust needed and none granted;
  `exec()`, `_.source`, hooks and tasks are refused; project `[env]`, `_.path`, `_.file` and
  `[settings]` are ignored. Use it to inspect an unfamiliar repo or to run
  `mise lock --bump --dry-run --json` on untrusted branches.
- **Paranoid mode** (`paranoid = true`, global): no implicit or worktree trust, trust bound to
  file contents (editing a file revokes it), env files trusted separately. Can be enabled per
  category.

## Lockfiles (`mise.lock`)

Exact versions, checksums, URLs and provenance per platform. Create with `mise lock`, or set
`lockfile = true` to keep one. Each config gets its own (`mise.ci.toml` → `mise.ci.lock`).

- Default `lockfile_mode = "generate"`: installs rebuild the lock from current requests and
  lock every platform, so a lock from one machine installs on another.
- `mise install --locked` (or `locked = true`) uses only lockfile URLs and fails on entries
  without checksums. Run `mise lock` once to fill them.
- `mise lock --bump` advances fuzzy requests (`latest`, `24`) in the lockfile only;
  `--platform linux-x64,macos-arm64` adds platforms; `--minimum-release-age 7d` holds back
  fresh versions.
- Lockfile format 4 (since 2026.11.1) is unreadable by older mise. Everyone sharing it needs
  `≥ 2026.11.1`; `mise lock --upgrade` moves an older lockfile to the new format.
- `npm:` tools are verified against Sigstore provenance by default, and the first install pins
  the building repository in the lockfile.

## Hooks

```toml
[hooks]
enter = "echo entering"          # needs `mise activate`; starts in the project root
leave = "echo leaving"           # needs `mise activate`
cd = "echo moved"                # needs `mise activate`
preinstall = "echo before"       # runs on `mise install`
postinstall = { task = "setup" } # a hook can run a task

[[watch_files]]                  # needs `mise activate`
patterns = ["src/**/*.rs"]
run = "cargo fmt"
```

Your Bash tool has no activation, so `enter`/`leave`/`cd`/`watch_files` never fire there.
Hooks get `MISE_PROJECT_ROOT`, `MISE_PREVIOUS_DIR`, `MISE_INSTALLED_TOOLS`.

## Templates (Tera v2)

Values render through Tera: `{{ config_root }}`, `{{ cwd }}`, `{{ env.HOME }}`,
`{{ vars.x }}`, `{{ tools.python.path }}` (with `tools = true`), `{{ mise_config_dir }}`,
`{{ exec(command="git rev-parse HEAD") }}`, `read_json/read_toml/read_yaml(path=…)`,
`os()`, `arch()`. Keep templates to paths and lookups; put logic in a task or script.
Templates that broke in the v2 upgrade can opt back with `[env] MISE_TERA_V1 = true` until
2027.4.0.
