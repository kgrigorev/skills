# expect: green
# A sub-package with its own __init__.py, and a test file per module.
mkdir -p src/sample_tool/text
printf '"""Text helpers."""\n' >src/sample_tool/text/__init__.py
cat >src/sample_tool/text/normalize.py <<'PY'
"""Normalise text before it is compared."""

import unicodedata


def normalize(text: str) -> str:
    """Return the text in NFC form, with runs of spaces made one space."""
    return " ".join(unicodedata.normalize("NFC", text).split())
PY
cat >tests/test_text_normalize.py <<'PY'
"""Tests for text normalisation."""

from sample_tool.text.normalize import normalize


def test_normalize_joins_combining_marks() -> None:
    assert normalize("é") == "é"


def test_normalize_collapses_spaces() -> None:
    assert normalize("  a \t b  ") == "a b"
PY
