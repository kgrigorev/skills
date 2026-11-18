# expect: red Tests
# An assume() that rejects every example, so the property checks nothing. Hypothesis fails
# the test (filter_too_much).
cat >tests/test_never.py <<'PY'
"""Tests that reject every example."""

from hypothesis import assume, given
from hypothesis import strategies as st

from sample_tool.core import slug


@given(st.text())
def test_slug_keeps_case(text: str) -> None:
    assume(len(text) < 0)
    assert slug(text) == text
PY
