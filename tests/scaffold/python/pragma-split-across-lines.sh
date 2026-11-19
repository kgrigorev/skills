# expect: red No switched-off checks
# coverage matches its pragma regex over the whole file with \s spanning a newline:
# "# pragma" at the end of the if line plus a name starting with "nocover" on the next line.
cat >src/sample_tool/shout.py <<'PY'
"""Shouting."""


def shout(text: str) -> str:
    """Shout the text."""
    if text == "secret":  # pragma
        nocover_note = "hidden"
        return text + nocover_note
    return text.upper()
PY
cat >tests/test_shout.py <<'PY'
"""Tests for shout."""

from sample_tool.shout import shout


def test_shout() -> None:
    assert shout("a") == "A"
PY
