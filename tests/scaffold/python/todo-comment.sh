# expect: red Lint
# A TODO left in the code (FIX002).
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    # TODO: count wide characters twice
    return len(text)
PY
