# expect: red No switched-off checks
# A failing check wrapped in pytest.raises(AssertionError): the test passes because the bug is
# there.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

import pytest

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    with pytest.raises(AssertionError):
        assert slug("A") == "A"
PY
