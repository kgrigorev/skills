from decimal import Decimal
from unittest.mock import MagicMock

import pytest

from billing import BillingService, Invoice


@pytest.fixture
def deps():
    return MagicMock(), MagicMock(), MagicMock()


def test_pay_charges_customer_and_publishes(deps):
    invoices, payments, events = deps
    invoices.get.return_value = Invoice("inv-1", "cust-1", Decimal("50"))
    payments.charge.return_value = "ch-1"
    service = BillingService(invoices, payments, events)

    assert service.pay("inv-1") == "ch-1"

    invoices.get.assert_called_once_with("inv-1")
    payments.charge.assert_called_once_with("cust-1", Decimal("50"))
    invoices.save.assert_called_once()
    events.publish.assert_called_once_with("invoice.paid", {"invoice_id": "inv-1", "charge_id": "ch-1"})


def test_pay_rejects_missing_invoice(deps):
    invoices, payments, events = deps
    invoices.get.return_value = None
    with pytest.raises(ValueError):
        BillingService(invoices, payments, events).pay("nope")
    payments.charge.assert_not_called()
