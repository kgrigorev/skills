# expect: red No switched-off checks
# Variant of raises-assertion-error: pytest.raises(Exception) with a match, which ruff's PT011
# accepts. Exception includes the AssertionError of the failing assert.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

import pytest

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    with pytest.raises(Exception, match="assert"):
        assert slug("A") == "A"
PY
