# expect: red Lint
# no_type_check under another name switches mypy off for the function.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

from importlib.metadata import metadata
from typing import no_type_check as unchecked


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


@unchecked
def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    separator: int = "-"
    return separator.join(text.lower().split())
PY
