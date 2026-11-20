# expect: red Lint
# A warning filter through an alias of the warnings module.
cat >tests/test_quiet.py <<'PY'
"""Tests that silence warnings."""

import warnings as w

from sample_tool.core import slug


def test_quiet() -> None:
    w.simplefilter("ignore")
    w.warn("hidden", DeprecationWarning, stacklevel=1)
    assert slug("a") == "a"
PY
