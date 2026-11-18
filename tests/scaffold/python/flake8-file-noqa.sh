# expect: red Lint
# A blanket flake8-style file exemption. ruff honours it, but PGH004 rejects a noqa that names no
# rule. flake8-file-noqa-with-code covers the form that names one.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""

# flake8: noqa
from importlib.metadata import metadata


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    unused = 1
    return "-".join(text.lower().split())
PY
