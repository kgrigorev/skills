# expect: red No switched-off checks
# A file-level mypy comment that switches off every error in the file.
cat >src/sample_tool/core.py <<'PY'
# mypy: ignore-errors
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
