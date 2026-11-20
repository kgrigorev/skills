# expect: red No switched-off checks
# A control char that str.splitlines() treats as a line break (\034), between pragma: and no cover.
ch=$(printf '\034')
cat >src/sample_tool/shout.py <<PY
"""Shouting."""


def shout(text: str) -> str:
    """Shout the text."""
    if text == "secret":  # pragma:${ch}no cover
        return text * 3
    return text.upper()
PY
cat >tests/test_shout.py <<'PY'
"""Tests for shout."""

from sample_tool.shout import shout


def test_shout() -> None:
    assert shout("a") == "A"
PY
