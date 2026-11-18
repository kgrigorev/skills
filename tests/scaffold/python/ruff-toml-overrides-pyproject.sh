# expect: red No switched-off checks
# ruff prefers ruff.toml over pyproject.toml.
cat >ruff.toml <<'TOML'
[lint]
select = ["E"]
TOML
cat >>src/sample_tool/core.py <<'PY'


def shout(text: str) -> None:
    """Print the text."""
    print(text)
PY
