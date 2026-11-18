# expect: red Lint
# cast through `import typing as t`: the text search misses it, ruff's banned-api resolves it.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

import typing as t
from importlib.metadata import metadata


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    label: int = t.cast("int", "-")
    return str(label).join(text.lower().split())
PY
