# expect: green
# A new module with a frozen dataclass, a custom error and tests for every branch.
cat >src/sample_tool/money.py <<'PY'
"""Amounts of money in whole cents."""

from dataclasses import dataclass
from typing import override

CENTS_PER_UNIT = 100
DECIMALS = 2


class AmountError(ValueError):
    """The text is not an amount such as "12.50"."""


@dataclass(frozen=True, slots=True)
class Amount:
    """An amount of money, in cents."""

    cents: int

    def __add__(self, other: Amount) -> Amount:
        """Add two amounts."""
        return Amount(self.cents + other.cents)

    @override
    def __str__(self) -> str:
        """Show the amount with two decimals, for example "12.50"."""
        sign = "-" if self.cents < 0 else ""
        whole, cents = divmod(abs(self.cents), CENTS_PER_UNIT)
        return f"{sign}{whole}.{cents:02d}"


def parse_amount(text: str) -> Amount:
    """Read an amount such as "12.50" or "-3".

    Raises:
        AmountError: the text is not an amount.
    """
    whole, _, fraction = text.strip().partition(".")
    negative = whole.startswith("-")
    digits = whole.removeprefix("-")
    fraction_ok = fraction == "" or fraction.isdigit()
    if not digits.isdigit() or len(fraction) > DECIMALS or not fraction_ok:
        msg = f"not an amount: {text!r}"
        raise AmountError(msg)
    cents = int(digits) * CENTS_PER_UNIT + int(fraction.ljust(DECIMALS, "0"))
    return Amount(-cents if negative else cents)
PY
cat >tests/test_money.py <<'PY'
"""Tests for amounts of money."""

import pytest

from sample_tool.money import Amount, AmountError, parse_amount


@pytest.mark.parametrize(
    ("text", "cents"),
    [("12.50", 1250), ("3", 300), ("-3.5", -350), (" 0.07 ", 7)],
)
def test_parse_amount_reads_cents(text: str, cents: int) -> None:
    assert parse_amount(text) == Amount(cents)


@pytest.mark.parametrize("text", ["", "abc", "1.234", "1.x", "--1"])
def test_parse_amount_rejects_other_text(text: str) -> None:
    with pytest.raises(AmountError, match="not an amount"):
        parse_amount(text)


def test_amounts_add_up() -> None:
    assert Amount(150) + Amount(-50) == Amount(100)


@pytest.mark.parametrize(
    ("cents", "text"), [(1250, "12.50"), (-7, "-0.07"), (0, "0.00")]
)
def test_str_shows_two_decimals(cents: int, text: str) -> None:
    assert str(Amount(cents)) == text
PY
