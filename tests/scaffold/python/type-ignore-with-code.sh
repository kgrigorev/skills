# expect: red No switched-off checks
# A type: ignore with an error code passes ruff and mypy, so only the search catches it.
cat >>src/sample_tool/core.py <<'PY'


def separator() -> str:
    """Return the separator."""
    value: int = "-"  # type: ignore[assignment]
    return str(value)
PY
cat >tests/test_separator.py <<'PY'
"""Tests for separator."""

from sample_tool.core import separator


def test_separator() -> None:
    assert separator() == "-"
PY
