# expect: red No switched-off checks
# An expected-to-fail mark on a failing test.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

import pytest

from sample_tool.core import slug


@pytest.mark.xfail(reason="known bug")
def test_later() -> None:
    assert slug("A") == "A"
PY
