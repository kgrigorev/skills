# expect: red Lint
# eval on input (S307, PGH001).
cat >>src/sample_tool/core.py <<'PY'


def total(text: str) -> int:
    """Add up an expression such as "1 + 2"."""
    return int(eval(text))
PY
