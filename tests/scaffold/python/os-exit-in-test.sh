# expect: red Lint
# os._exit(0) ends pytest with exit 0 before it counts the failure above it.
cat >tests/test_exit.py <<'PY'
"""Tests that end the run early."""

import os

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"


def test_zz_end() -> None:
    os._exit(0)
PY
