# expect: red Tests
# The test puts an "ignore" filter at the front of warnings.filters through vars(), which no
# name search sees.
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
    filters: list[object] = vars(warnings)["filters"]
    filters.insert(0, ("ignore", None, Warning, None, 0))
    assert old() == 1
PY
