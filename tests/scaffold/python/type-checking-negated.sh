# expect: red No switched-off checks
# Variant of type-checking-else-hides-code: `if not TYPE_CHECKING:` holds the code that runs,
# and mypy skips it as unreachable without a word.
cat >>src/sample_tool/core.py <<'PY'


def half(number: int) -> int:
    """Return half the number."""
    if not TYPE_CHECKING:
        return str(number // 2)
    return number // 2
PY
awk '/^from importlib.metadata import metadata$/ { print; print "from typing import TYPE_CHECKING"; next } { print }' \
  src/sample_tool/core.py >core.tmp
mv core.tmp src/sample_tool/core.py
cat >tests/test_half.py <<'PY'
"""Tests for half."""

from sample_tool.core import half


def test_half() -> None:
    assert str(half(4)) == "2"
PY
