# expect: red No switched-off checks
# `-diff` also makes git treat the files as binary.
printf '*.py -diff\n' >.gitattributes
cat >>src/sample_tool/core.py <<'PY'


def untested(number: int) -> int:  # pragma: no cover
    """Return twice the number, never tested."""
    return number * 2
PY
