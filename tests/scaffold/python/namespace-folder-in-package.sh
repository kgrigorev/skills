# expect: red Lint
# coverage does not look for unrun files in a folder without __init__.py; ruff's INP001
# rejects the folder.
mkdir -p src/sample_tool/extra
cat >src/sample_tool/extra/helper.py <<'PY'
"""Extra."""


def extra() -> int:
    """Return one."""
    return 1
PY
