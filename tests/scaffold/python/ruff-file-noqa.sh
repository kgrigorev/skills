# expect: red No switched-off checks
# A file-level ruff exemption for one rule.
cat >src/sample_tool/core.py <<'PY'
"""The library: all the program's logic lives here."""
# ruff: noqa: T201

from importlib.metadata import metadata


def banner() -> str:
    """Return the line the program prints when it starts."""
    about = metadata("sample-tool")
    return f"{about['Name']}: {about['Summary']}"


def slug(text: str) -> str:
    """Turn text into lower-case words joined by "-", for example "A b" -> "a-b"."""
    print(text)
    return "-".join(text.lower().split())
PY
