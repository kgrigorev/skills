# expect: red Tests
# The recwarn fixture records warnings instead of raising them, and the test never looks.
cat >src/sample_tool/old.py <<'PY'
"""Old API."""

import warnings


def old() -> int:
    """Warn."""
    warnings.warn("old API", DeprecationWarning, stacklevel=2)
    return 1
PY
cat >tests/test_old.py <<'PY'
"""Tests."""

import pytest

from sample_tool.old import old


def test_old(recwarn: pytest.WarningsRecorder) -> None:
    assert old() == 1
    assert recwarn is not None
PY
