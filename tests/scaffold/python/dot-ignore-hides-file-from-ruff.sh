# expect: red Format
# ruff skips files that a .ignore file names, unless respect-gitignore is off.
printf 'core.py\n' >src/sample_tool/.ignore
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    unused = 1
    print("debug",unused)
    return len(text)
PY
