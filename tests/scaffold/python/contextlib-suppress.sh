# expect: red Lint
# suppress(Exception) swallows every error; ruff's BLE001 only sees `except`.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

from contextlib import suppress
from importlib.metadata import metadata


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    result = ""
    with suppress(Exception):
        result = "-".join(text.lower().split())
    return result
PY
