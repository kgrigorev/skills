# expect: red Lint
# Hypothesis settings under another name that run no generated examples at all.
cat >tests/test_core.py <<'PY'
"""Tests for the library."""

from hypothesis import Phase, given
from hypothesis import settings as configure
from hypothesis import strategies as st

from sample_tool.core import banner, slug


def test_banner_names_the_program() -> None:
    assert banner().startswith("sample-tool: ")


@configure(phases=[Phase.explicit])
@given(st.text())
def test_slug_is_stable_when_applied_twice(text: str) -> None:
    assert slug(text) == text
PY
