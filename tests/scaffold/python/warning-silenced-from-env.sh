# expect: red Tests
# env: PYTEST_ADDOPTS=-pno:warnings
# env: PYTHONWARNINGS=ignore
# The caller's environment must not switch the warning gate off.
cat >tests/test_old.py <<'PY'
"""Tests that warn."""

import warnings

from sample_tool.core import slug


def test_old() -> None:
    warnings.warn("old", DeprecationWarning, stacklevel=1)
    assert slug("a") == "a"
PY
