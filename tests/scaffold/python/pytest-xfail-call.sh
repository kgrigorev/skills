# expect: red Lint
# pytest.xfail imported by name.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

from pytest import xfail

from sample_tool.core import slug


def test_later() -> None:
    xfail("known bug")
    assert slug("A") == "A"
PY
