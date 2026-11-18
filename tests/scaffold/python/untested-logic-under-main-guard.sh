# expect: red Tests
# Well-typed logic under a `__name__` guard in the library. No test runs it, so coverage
# must count it.
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
    return "-".join(text.lower().split())


if __name__ == "__main__":
    words = slug(" ".join(sys.argv[1:])).split("-")
    longest = max(words, key=len) if words else ""
    sys.stdout.write(f"{longest}\n")
PY
