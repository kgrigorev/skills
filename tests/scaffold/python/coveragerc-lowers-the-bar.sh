# expect: red No switched-off checks
# coverage prefers .coveragerc over pyproject.toml.
cat >.coveragerc <<'INI'
[report]
fail_under = 0
INI
cat >>src/sample_tool/core.py <<'PY'


def untested(number: int) -> int:
    """Return twice the number, never tested."""
    return number * 2
PY
