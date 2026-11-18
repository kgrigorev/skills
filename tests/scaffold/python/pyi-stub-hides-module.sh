# expect: red No switched-off checks
# mypy reads core.pyi instead of core.py, so the type error in core.py is never seen.
cat >src/sample_tool/core.pyi <<'PY'
def banner() -> str: ...
def slug(text: str) -> str: ...
PY
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

from importlib.metadata import metadata


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    separator: int = "-"
    return separator.join(text.lower().split())
PY
