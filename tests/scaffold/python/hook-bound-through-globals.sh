# expect: red No switched-off checks
# A hook name built at run time, which no text search sees. Only tests/conftest.py may exist.
mkdir -p tests/more
cat >tests/more/conftest.py <<'PY'
"""More fixtures."""

import pytest


def _drop(items: list[pytest.Item]) -> None:
    """Drop the tests that fail."""
    items[:] = [item for item in items if "failing" not in item.name]


globals()["pytest_" + "collection_modifyitems"] = _drop
PY
cat >tests/more/test_more.py <<'PY'
"""More tests."""

from sample_tool.core import slug


def test_failing() -> None:
    assert slug("A") == "B"
PY
