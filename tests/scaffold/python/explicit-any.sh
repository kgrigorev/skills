# expect: red Lint
# Any switches the type checker off for a value (ANN401; mypy's disallow_any_explicit too).
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

from importlib.metadata import metadata
from typing import Any


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: Any) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    return "-".join(text.lower().split())
PY
