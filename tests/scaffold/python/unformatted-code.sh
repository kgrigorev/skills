# expect: red Format
# Code that ruff format would change.
cat >>src/sample_tool/core.py <<'PY'


def double(number: int) -> int:
    """Return twice the number."""
    return number*2
PY
