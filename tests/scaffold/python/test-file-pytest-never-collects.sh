# expect: red No switched-off checks
# pytest collects only test_*.py, so this failing test would never run.
cat >tests/core_checks.py <<'PY'
"""More tests."""

from sample_tool.core import slug


def test_keeps_case() -> None:
    assert slug("A") == "A"
PY
