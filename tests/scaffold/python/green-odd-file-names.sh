# expect: green
# Valid module and test names with digits, double underscores and non-ASCII letters.
cat >src/sample_tool/v2__format.py <<'PY'
"""Version 2 of the output format."""


def header(columns: list[str]) -> str:
    """Return the header line."""
    return "\t".join(columns)
PY
cat >tests/test_v2__format.py <<'PY'
"""Tests for version 2 of the output format."""

from sample_tool.v2__format import header


def test_header_joins_with_tabs() -> None:
    assert header(["a", "b"]) == "a\tb"
PY
cat >tests/test_slug_für_umlaute.py <<'PY'
"""Tests for slug with non-ASCII text."""

from sample_tool.core import slug


def test_slug_keeps_umlauts() -> None:
    assert slug("Für Umlaute") == "für-umlaute"
PY
