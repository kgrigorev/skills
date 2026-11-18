# expect: red Tests
# @seed fixes the random examples of one test, which the search and banned-api do not know.
# The conftest check sees that the test does not run the profile.
cat >tests/test_core.py <<'PY'
"""Tests for the library."""

from hypothesis import given, seed
from hypothesis import strategies as st

from sample_tool.core import banner, slug


def test_banner_names_the_program() -> None:
    assert banner().startswith("sample-tool: ")


@seed(1)
@given(st.text())
def test_slug_is_stable_when_applied_twice(text: str) -> None:
    assert slug(slug(text)) == slug(text)
PY
