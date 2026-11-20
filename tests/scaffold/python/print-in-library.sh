# expect: red Lint
# A leftover print in the library (T201).
cat >>src/sample_tool/core.py <<'PY'


def shout(text: str) -> None:
    """Print the text."""
    print(text)
PY
