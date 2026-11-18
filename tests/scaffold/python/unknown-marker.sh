# expect: red Tests
# pytest's strict mode makes an unregistered marker an error.
cat >tests/test_slow.py <<'PY'
"""Slow tests."""

import pytest

from sample_tool.core import slug


@pytest.mark.slowish
def test_slug() -> None:
    assert slug("A b") == "a-b"
PY
