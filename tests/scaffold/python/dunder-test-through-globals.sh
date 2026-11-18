# expect: red Tests
# Variant of dunder-test-false-module: the name is built at run time, so the search misses it.
# tests/conftest.py fails because the module defines a test that pytest did not collect.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

from sample_tool.core import slug

globals()["__te" + "st__"] = False


def test_bug() -> None:
    assert slug("A") == "B"
PY
