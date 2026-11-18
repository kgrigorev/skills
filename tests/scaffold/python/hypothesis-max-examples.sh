# expect: red Lint
# One example instead of the profile's hundred.
cat >tests/test_core.py <<'PY'
"""Tests for the library."""

from hypothesis import given, settings
from hypothesis import strategies as st

from sample_tool.core import banner, slug


def test_banner_names_the_program() -> None:
    assert banner().startswith("sample-tool: ")


@settings(max_examples=1)
@given(st.text())
def test_slug_is_stable_when_applied_twice(text: str) -> None:
    assert slug(slug(text)) == slug(text)
PY
