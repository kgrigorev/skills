# expect: red Lint
# pytest.skip under an alias: banned-api resolves it.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

import pytest as pt

from sample_tool.core import slug


def test_later() -> None:
    pt.skip("later")
    assert slug("A") == "A"
PY
