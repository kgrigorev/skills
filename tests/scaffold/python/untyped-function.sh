# expect: red Lint
# A function without annotations (ANN001, ANN201; mypy --strict too).
cat >>src/sample_tool/core.py <<'PY'


def half(number):
    """Return half the number."""
    return number // 2
PY
