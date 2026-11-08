import re
import unicodedata


def slugify(text: str, max_length: int | None = None) -> str:
    """Turn arbitrary text into a URL slug: lowercase ASCII words joined by single hyphens."""
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text).strip("-").lower()
    if max_length is not None and len(text) > max_length:
        text = text[:max_length].rstrip("-")
    return text
