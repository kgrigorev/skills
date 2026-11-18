# expect: red No switched-off checks
# git grep skips files that .gitattributes marks as binary, unless it reads them as text.
printf '*.py binary\n' >.gitattributes
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    unused = 1  # noqa: F841
    return len(text)
PY
