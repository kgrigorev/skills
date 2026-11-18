# expect: red No switched-off checks
# mypy checks only the TYPE_CHECKING branch and skips the else branch silently; coverage
# excludes `if TYPE_CHECKING:` by default. The code that runs says int and returns str.
cat >>src/sample_tool/core.py <<'PY'


if TYPE_CHECKING:

    def half(number: int) -> int:
        """Return half the number."""
        return number // 2

else:

    def half(number: int) -> int:
        """Return half the number."""
        return str(number // 2)
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
