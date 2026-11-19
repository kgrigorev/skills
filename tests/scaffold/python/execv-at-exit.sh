# expect: red Lint
# os.execv at exit replaces the process after coverage saved its data; true exits 0.
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
cat >tests/test_zz_exit.py <<'PY'
"""Runs last."""

import atexit
import os


def test_exit() -> None:
    atexit.register(os.execv, "/usr/bin/true", ["true"])
PY
