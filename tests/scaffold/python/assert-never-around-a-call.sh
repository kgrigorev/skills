# expect: red Tests
# Coverage skips a line that is only `assert_never(name)`. A call inside the parentheses is real
# code (a function that returns NoReturn type-checks there), so its line still needs a test.
cat >>src/sample_tool/core.py <<'PY'


def check_count(count: int) -> int:
    """Return the count, or stop the program when it is negative."""
    if count < 0:
        assert_never(sys.exit(f"negative count: {count}"))
    return count
PY
awk '/^from importlib.metadata import metadata$/ { print "import sys"; print; print "from typing import assert_never"; next } { print }' \
  src/sample_tool/core.py >core.tmp
mv core.tmp src/sample_tool/core.py
cat >tests/test_count.py <<'PY'
"""Tests for check_count."""

from sample_tool.core import check_count


def test_check_count_keeps_a_positive_count() -> None:
    assert check_count(3) == 3
PY
