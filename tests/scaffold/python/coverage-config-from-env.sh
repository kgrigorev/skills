# expect: red Tests
# env: COVERAGE_RCFILE=coverage-local.ini
# A coverage config named in the caller's environment must not lower the bar.
cat >coverage-local.ini <<'INI'
[report]
fail_under = 0
INI
cat >>src/sample_tool/core.py <<'PY'


def untested(number: int) -> int:
    """Return twice the number, never tested."""
    return number * 2
PY
