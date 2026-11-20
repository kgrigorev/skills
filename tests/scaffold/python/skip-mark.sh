# expect: red No switched-off checks
# A skip mark.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

import pytest

from sample_tool.core import slug


@pytest.mark.skip(reason="later")
def test_later() -> None:
    assert slug("A") == "A"
PY
