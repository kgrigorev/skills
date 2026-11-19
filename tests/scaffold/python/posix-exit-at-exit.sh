# expect: red Lint
# leave is os._exit under another module name, which banned-api does not list. Registered
# with atexit, it runs after coverage has saved its data and replaces the exit status.
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
cat >tests/test_zz_exit.py <<'PY'
"""Runs last."""

import atexit
from posix import _exit as leave


def test_exit() -> None:
    atexit.register(leave, 0)
PY
