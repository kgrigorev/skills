# expect: red Lint
# A plain typing.cast that tells mypy a str is an int.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

from importlib.metadata import metadata
from typing import cast


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    label: int = cast("int", "-")
    return str(label).join(text.lower().split())
PY
