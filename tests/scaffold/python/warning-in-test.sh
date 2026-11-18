# expect: red Tests
# A warning is a failure.
cat >tests/test_old.py <<'PY'
"""Tests that warn."""

import warnings

from sample_tool.core import slug


def test_old() -> None:
    warnings.warn("old", DeprecationWarning, stacklevel=1)
    assert slug("a") == "a"
PY
