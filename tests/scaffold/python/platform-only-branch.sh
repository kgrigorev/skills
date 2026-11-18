# expect: red Lint
# A macOS-only branch: mypy checks as Linux and skips it, and the tests never run it on CI.
# ruff bans sys.platform; coverage would fail too, because no test covers both outcomes.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

import sys
from importlib.metadata import metadata


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    if sys.platform == "darwin":
        separator: int = "-"
        return separator.join(text.lower().split())
    return "-".join(text.lower().split())
PY
