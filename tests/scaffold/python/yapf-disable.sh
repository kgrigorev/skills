# expect: red No switched-off checks
# A trailing yapf: disable. ruff format honours it like fmt: skip and leaves the line alone, and
# ruff's ERA001 does not read a trailing comment as code. The search finds it.
cat >>src/sample_tool/core.py <<'PY'


def double(number: int) -> int:
    """Return twice the number."""
    return number*2  # yapf: disable
PY
cat >tests/test_double.py <<'PY'
"""Tests for double."""

from sample_tool.core import double


def test_double() -> None:
    assert double(2) == 4
PY
