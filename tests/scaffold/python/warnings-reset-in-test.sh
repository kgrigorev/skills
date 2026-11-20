# expect: red Lint
# warnings.resetwarnings() removes pytest's "error" filter, so the warning is only printed.
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

import warnings

from sample_tool.old import old


def test_old() -> None:
    warnings.resetwarnings()
    assert old() == 1
PY
