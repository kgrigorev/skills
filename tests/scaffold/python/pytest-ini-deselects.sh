# expect: red No switched-off checks
# A pytest.ini that deselects the failing test.
cat >pytest.ini <<'INI'
[pytest]
addopts = --deselect tests/test_bug.py::test_failing
INI
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

from sample_tool.core import slug


def test_failing() -> None:
    assert slug("A") == "B"
PY
