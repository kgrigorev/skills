# expect: red Tests
# A test that fails.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
