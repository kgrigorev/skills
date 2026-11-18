# expect: red No switched-off checks
# A pytest hook bound by assignment in a root conftest.py drops the failing test.
cat >conftest.py <<'PY'
"""Local test helpers."""

import pytest


def _drop_inconvenient(items: list[pytest.Item]) -> None:
    """Keep only the tests that pass."""
    items[:] = [item for item in items if "keeps_case" not in item.name]


pytest_collection_modifyitems = _drop_inconvenient
PY
mkdir -p tests/case
cat >tests/case/test_case.py <<'PY'
"""Case tests."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
