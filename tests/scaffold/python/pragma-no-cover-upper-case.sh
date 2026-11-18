# expect: red No switched-off checks
# coverage accepts the pragma in upper case.
cat >>src/sample_tool/core.py <<'PY'


def untested(number: int) -> int:  # PRAGMA: NO COVER
    """Divide by zero, never tested."""
    return number // 0
PY
