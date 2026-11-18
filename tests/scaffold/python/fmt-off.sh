# expect: red No switched-off checks
# ruff format leaves code between fmt: off and fmt: on alone.
cat >>src/sample_tool/core.py <<'PY'


# fmt: off
def double(number: int) -> int:
    """Return twice the number."""
    return number*2
# fmt: on
PY
cat >tests/test_double.py <<'PY'
"""Tests for double."""

from sample_tool.core import double


def test_double() -> None:
    assert double(2) == 4
PY
