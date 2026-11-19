# expect: red No switched-off checks
# coverage's default exclusion "^\s*if (typing\.)?TYPE_CHECKING:" also matches a line inside a
# multi-line string in an if condition, and the whole if block is excluded.
cat >src/sample_tool/shout.py <<'PY'
"""Shouting."""


def shout(text: str) -> str:
    """Shout the text."""
    if text in """
if TYPE_CHECKING:
""":
        return "hidden"
    return text.upper()
PY
cat >tests/test_shout.py <<'PY'
"""Tests for shout."""

from sample_tool.shout import shout


def test_shout() -> None:
    assert shout("a") == "A"
PY
mise --quiet exec -- uv run --no-sync ruff format --quiet src
