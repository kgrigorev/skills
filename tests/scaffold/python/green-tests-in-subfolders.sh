# expect: green
# Tests grouped in folders, each with a test_core.py of its own.
mkdir -p tests/unit tests/cli
cat >tests/unit/test_core.py <<'PY'
"""Unit tests for slug."""

from sample_tool.core import slug


def test_slug_joins_words() -> None:
    assert slug("A b") == "a-b"
PY
cat >tests/cli/test_core.py <<'PY'
"""Command tests that touch the library."""

from sample_tool.core import banner


def test_banner_has_a_summary() -> None:
    assert ": " in banner()
PY
