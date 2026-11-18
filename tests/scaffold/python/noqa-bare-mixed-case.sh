# expect: red Lint
# A blanket noqa in mixed case. ruff rejects blanket noqa comments (PGH004).
cat >>src/sample_tool/core.py <<'PY'


def width(text: str) -> int:
    """Return the length of the text."""
    unused = 1  # NoQA
    return len(text)
PY
