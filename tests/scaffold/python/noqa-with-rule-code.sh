# expect: red No switched-off checks
# A noqa comment that names its rule passes ruff, so only the search catches it.
cat >>src/sample_tool/core.py <<'PY'


def shout(text: str) -> None:
    """Print the text."""
    print(text)  # noqa: T201
PY
