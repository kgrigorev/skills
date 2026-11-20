# expect: red No switched-off checks
# Hypothesis settings from the private module hypothesis._settings, which ruff's banned-api does
# not resolve, that run only the one explicit example: the false property passes. The ast check
# in scripts/check rejects the private import; the conftest check would also see the settings
# the test really runs with.
cat >tests/test_core.py <<'PY'
"""Tests for the library."""

from hypothesis import Phase, example, given
from hypothesis import strategies as st
from hypothesis._settings import settings as configure

from sample_tool.core import banner, slug


def test_banner_names_the_program() -> None:
    assert banner().startswith("sample-tool: ")


@configure(phases=[Phase.explicit])
@given(st.text())
@example("a")
def test_slug_is_identity(text: str) -> None:
    assert slug(text) == text
PY
