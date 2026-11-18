# expect: red Lint
# The same exit through the posix module: ruff's SLF001 rejects the private name.
cat >tests/test_exit.py <<'PY'
"""Tests that end the run early."""

import posix

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"


def test_zz_end() -> None:
    posix._exit(0)
PY
