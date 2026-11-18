# expect: red Tests
# A new module that no test imports still counts against coverage.
cat >src/sample_tool/extra.py <<'PY'
"""Extra."""


def extra() -> int:
    """Return one."""
    return 1
PY
