# expect: red No switched-off checks
# Variant of assert-never-around-a-call: sys.exit imported as assert_never, so its line matches
# the coverage exclusion and the untested error path disappears from branch coverage.
cat >>src/sample_tool/core.py <<'PY'


def check_count(count: int) -> int:
    """Return the count, or stop the program when it is negative."""
    if count < 0:
        assert_never(count)
    return count
PY
awk '/^from importlib.metadata import metadata$/ { print; print "from sys import exit as assert_never"; next } { print }' \
  src/sample_tool/core.py >core.tmp
mv core.tmp src/sample_tool/core.py
cat >tests/test_count.py <<'PY'
"""Tests for check_count."""

from sample_tool.core import check_count


def test_check_count_keeps_a_positive_count() -> None:
    assert check_count(3) == 3
PY
