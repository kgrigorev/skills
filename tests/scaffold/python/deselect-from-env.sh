# expect: red Tests
# env: PYTEST_ADDOPTS=--deselect=tests/test_core.py::test_banner_names_the_program
# A deselect in the caller's environment must not hide a failing test.
cat >tests/test_core.py <<'PY'
"""Tests for the library."""

from hypothesis import given
from hypothesis import strategies as st

from sample_tool.core import banner, slug


def test_banner_names_the_program() -> None:
    assert banner().startswith("other: ")


@given(st.text())
def test_slug_is_stable_when_applied_twice(text: str) -> None:
    assert slug(slug(text)) == slug(text)
PY
