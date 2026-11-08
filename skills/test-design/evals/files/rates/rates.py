from decimal import Decimal
import requests

RATES_URL = "https://api.example-rates.com/latest"


def convert(amount: Decimal, from_currency: str, to_currency: str) -> Decimal:
    if from_currency == to_currency:
        return amount
    resp = requests.get(RATES_URL, params={"base": from_currency}, timeout=5)
    resp.raise_for_status()
    rate = Decimal(str(resp.json()["rates"][to_currency]))
    return (amount * rate).quantize(Decimal("0.01"))
