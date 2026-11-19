# expect: red Lint
# An em space (U+2003) between "pragma:" and "no cover", which coverage reads as a space and the
# text search does not. ruff's RUF003 (ambiguous Unicode in a comment) rejects it first; the ast
# check in scripts/check uses coverage's own pattern and would reject it too.
em=$(printf '\342\200\203')
cat >src/sample_tool/shout.py <<PY
"""Shouting."""


def shout(text: str) -> str:
    """Shout the text."""
    if text == "secret":  # pragma:${em}no cover
        return text * 3
    return text.upper()
PY
cat >tests/test_shout.py <<'PY'
"""Tests for shout."""

from sample_tool.shout import shout


def test_shout() -> None:
    assert shout("a") == "A"
PY
