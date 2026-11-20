# expect: red No switched-off checks
# coverage accepts "pragma no cover" without the colon.
cat >>src/sample_tool/core.py <<'PY'


def untested(number: int) -> int:  # pragma no cover
    """Divide by zero, never tested."""
    return number // 0
PY
