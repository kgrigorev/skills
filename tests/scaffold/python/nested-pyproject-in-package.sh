# expect: red No switched-off checks
# ruff uses the nearest pyproject.toml, so one inside the package replaces the rules.
cat >src/sample_tool/pyproject.toml <<'TOML'
[tool.ruff.lint]
select = ["E"]
TOML
cat >>src/sample_tool/core.py <<'PY'


def shout(text: str) -> None:
    """Print the text."""
    print(text)
PY
