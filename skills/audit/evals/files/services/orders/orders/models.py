from dataclasses import dataclass, field

from orders.pricing import order_total


@dataclass
class Line:
    sku: str
    quantity: int
    unit_price: float
    category: str


@dataclass
class Order:
    customer_tier: str
    coupon: str | None
    lines: list[Line] = field(default_factory=list)

    def total(self) -> float:
        return order_total(self)
