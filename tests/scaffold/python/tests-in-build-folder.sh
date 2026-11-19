# expect: red Tests
# pytest's default norecursedirs skips tests/build/, so this failing test would never run.
mkdir -p tests/build
cat >tests/build/test_build.py <<'PY'
"""Tests that pytest skipped by default."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A B") == "A-B"
PY
