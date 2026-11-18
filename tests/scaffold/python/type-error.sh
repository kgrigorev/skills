# expect: red Types
# A float returned where the signature says int.
cat >>src/sample_tool/core.py <<'PY'


def half(number: int) -> int:
    """Return half the number."""
    return number / 2
PY
