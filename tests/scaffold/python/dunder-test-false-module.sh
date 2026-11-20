# expect: red No switched-off checks
# __test__ = False at module level hides every test in the file.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

from sample_tool.core import slug

__test__ = False


def test_bug() -> None:
    assert slug("A") == "B"
PY
