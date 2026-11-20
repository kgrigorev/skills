# expect: red Format
# A tracked file that .gitignore names stays tracked, but ruff would skip it.
printf 'src/sample_tool/core.py\n' >>.gitignore
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    unused = 1
    print("debug",unused)
    return len(text)
PY
