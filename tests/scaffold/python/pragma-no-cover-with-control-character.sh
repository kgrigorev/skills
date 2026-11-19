# expect: red No switched-off checks
# A unit separator (U+001F) between "pragma:" and "no cover": coverage's pattern reads it as a
# space, the text search does not, and most diffs do not show it.
us=$(printf '\037')
cat >src/sample_tool/shout.py <<PY
"""Shouting."""


def shout(text: str) -> str:
    """Shout the text."""
    if text == "secret":  # pragma:${us}no cover
        return text * 3
    return text.upper()
PY
cat >tests/test_shout.py <<'PY'
"""Tests for shout."""

from sample_tool.shout import shout


def test_shout() -> None:
    assert shout("a") == "A"
PY
