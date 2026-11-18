# expect: red No switched-off checks
# coverage measures only the project's package; a second one would go unmeasured.
mkdir -p src/helpers
printf '"""Helpers."""\n' >src/helpers/__init__.py
cat >src/helpers/double.py <<'PY'
"""Doubling."""


def double(number: int) -> int:
    """Return twice the number."""
    return number * 2
PY
