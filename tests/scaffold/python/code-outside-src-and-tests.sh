# expect: red No switched-off checks
# A tools/ folder is linted but never type-checked, measured or run.
mkdir -p tools
printf '"""Helper scripts."""\n' >tools/__init__.py
cat >tools/half.py <<'PY'
"""Halve numbers."""


def half(number: int) -> str:
    """Return half of a number."""
    return number // 2
PY
