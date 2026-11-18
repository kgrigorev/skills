# expect: red Lint
# ruff format honours yapf: disable like fmt: off, but ruff's ERA001 reads the yapf comments as
# commented-out code, so lint fails before the search runs.
cat >>src/sample_tool/core.py <<'PY'


# yapf: disable
def double(number: int) -> int:
    """Return twice the number."""
    return number+   2
# yapf: enable
PY
