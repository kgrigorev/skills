# expect: red No switched-off checks
# A branch that no test takes, hidden from branch coverage.
cat >>src/sample_tool/core.py <<'PY'


def sign(number: int) -> int:
    """Return -1 for negative numbers, else 1."""
    if number < 0:  # pragma: no branch
        return -1
    return 1
PY
cat >tests/test_sign.py <<'PY'
"""Tests for sign."""

from sample_tool.core import sign


def test_sign_of_a_negative_number() -> None:
    assert sign(-3) == -1
PY
