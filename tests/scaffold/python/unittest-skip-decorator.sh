# expect: red Lint
# A unittest skip decorator imported by name.
cat >tests/test_later.py <<'PY'
"""Tests for later."""

from unittest import skip

from sample_tool.core import slug


@skip("later")
def test_later() -> None:
    assert slug("A") == "A"
PY
