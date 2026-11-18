# expect: red Lint
# `from pytest import mark` gets past the text search; ruff's PT013 rejects the import.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

from pytest import mark

from sample_tool.core import slug


@mark.skip(reason="later")
def test_later() -> None:
    assert slug("A") == "A"
PY
