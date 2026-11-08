from orders import models


def order_total(order: "models.Order") -> float:
    if not order.lines:
        return 0.0

    total = 0.0
    for line in order.lines:
        price = line.unit_price * line.quantity
        if line.quantity > 0:
            if order.customer_tier == "gold":
                if line.category == "books":
                    if line.quantity >= 10:
                        price = price * 0.80
                    else:
                        price = price * 0.90
                elif line.category == "electronics":
                    if line.quantity >= 3:
                        price = price * 0.92
                    else:
                        price = price * 0.95
                else:
                    price = price * 0.97
            elif order.customer_tier == "silver":
                if line.category == "books":
                    if line.quantity >= 10:
                        price = price * 0.85
                    else:
                        price = price * 0.95
                elif line.category == "electronics":
                    price = price * 0.97
            else:
                if line.quantity >= 20:
                    price = price * 0.98
            if order.coupon is not None:
                if order.coupon.startswith("PCT"):
                    try:
                        pct = int(order.coupon[3:])
                        if 0 < pct <= 50:
                            price = price * (100 - pct) / 100
                    except ValueError:
                        pass
                elif order.coupon.startswith("OFF"):
                    try:
                        off = float(order.coupon[3:])
                        if off < price:
                            price = price - off
                        else:
                            price = 0.0
                    except ValueError:
                        pass
        else:
            price = 0.0
        total += price
    if order.customer_tier == "gold":
        if total > 1000:
            total = total - 50
    elif order.customer_tier == "silver":
        if total > 1000:
            total = total - 20
    if total < 0:
        total = 0.0
    return round(total, 2)
