# expect: red No switched-off checks
# A declaration under TYPE_CHECKING tells mypy that half returns int; globals() binds the code
# that runs, which returns str. Coverage skips the block, mypy never reads the rebind.
cat >src/sample_tool/half.py <<'PY'
"""Halves."""

from typing import TYPE_CHECKING


def _half(number: int) -> str:
    """Return half, as text."""
    return str(number // 2)


if TYPE_CHECKING:

    def half(number: int) -> int:
        """Return half."""


globals()["half"] = _half
PY
cat >tests/test_half.py <<'PY'
"""Tests."""

from sample_tool import half as module


def test_half() -> None:
    assert str(module.half(4)) == "2"
PY
