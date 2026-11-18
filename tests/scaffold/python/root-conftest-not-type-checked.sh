# expect: red No switched-off checks
# A conftest.py at the root is outside mypy's files.
cat >conftest.py <<'PY'
"""Fixtures."""

import pytest


@pytest.fixture
def separator() -> int:
    """Return the separator."""
    return "-"
PY
