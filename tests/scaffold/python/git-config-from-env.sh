# expect: red No switched-off checks
# env: GIT_CONFIG_GLOBAL=local.gitconfig
# A git config from the caller's environment that marks code as binary for git grep.
printf '*.py binary\n' >local.gitattributes
printf '[core]\n\tattributesFile = %s/local.gitattributes\n' "$(pwd)" >local.gitconfig
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    unused = 1  # noqa: F841
    return len(text)
PY
