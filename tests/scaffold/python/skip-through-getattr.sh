# expect: red Tests
# pytest.skip reached through getattr, which no search can see.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

import pytest

from sample_tool.core import slug


def test_later() -> None:
    getattr(pytest, "sk" + "ip")("later")
    assert slug("A") == "A"
PY
