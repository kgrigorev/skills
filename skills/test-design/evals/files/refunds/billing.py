from dataclasses import dataclass
from decimal import Decimal


@dataclass
class Invoice:
    id: str
    customer_id: str
    amount: Decimal
    refunded: Decimal = Decimal("0")
    status: str = "open"


class BillingService:
    def __init__(self, invoices, payments, events):
        self.invoices = invoices   # .get(id) -> Invoice | None, .save(invoice)
        self.payments = payments   # .charge(customer_id, amount) -> str, .refund(customer_id, amount) -> str
        self.events = events       # .publish(name, payload)

    def pay(self, invoice_id: str) -> str:
        invoice = self.invoices.get(invoice_id)
        if invoice is None or invoice.status != "open":
            raise ValueError("invoice not payable")
        charge_id = self.payments.charge(invoice.customer_id, invoice.amount)
        invoice.status = "paid"
        self.invoices.save(invoice)
        self.events.publish("invoice.paid", {"invoice_id": invoice.id, "charge_id": charge_id})
        return charge_id

    def refund(self, invoice_id: str, amount: Decimal) -> str:
        invoice = self.invoices.get(invoice_id)
        if invoice is None or invoice.status not in ("paid", "partially_refunded"):
            raise ValueError("invoice not refundable")
        if amount <= 0 or invoice.refunded + amount > invoice.amount:
            raise ValueError("invalid refund amount")
        refund_id = self.payments.refund(invoice.customer_id, amount)
        invoice.refunded += amount
        invoice.status = "refunded" if invoice.refunded == invoice.amount else "partially_refunded"
        self.invoices.save(invoice)
        self.events.publish("invoice.refunded", {"invoice_id": invoice.id, "amount": str(amount)})
        return refund_id
