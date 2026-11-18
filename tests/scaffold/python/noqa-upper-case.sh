# expect: red No switched-off checks
# ruff honours an upper-case noqa comment, so the search must ignore case.
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    unused = 1  # NOQA: F841
    return len(text)
PY
