# expect: red No switched-off checks
# Variant of raises-assertion-error: the test catches the failing assert and logs it, which
# ruff's BLE001 accepts because the handler logs the exception.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

import logging

from sample_tool.core import slug

logger = logging.getLogger(__name__)


def test_slug_keeps_case() -> None:
    try:
        assert slug("A") == "A"
    except Exception:
        logger.exception("slug changed the case")
PY
