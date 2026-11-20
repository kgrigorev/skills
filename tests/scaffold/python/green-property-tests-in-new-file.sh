# expect: green
# Property tests in a new file: a composite strategy, assume() that rejects few examples,
# and an explicit @example.
cat >tests/test_slug_properties.py <<'PY'
"""Properties of slug."""

from hypothesis import assume, example, given
from hypothesis import strategies as st

from sample_tool.core import slug

words = st.lists(st.text(alphabet="abcxyz", min_size=1), min_size=1)


@st.composite
def sentences(draw: st.DrawFn) -> str:
    """Draw words joined by runs of spaces."""
    parts = draw(words)
    gaps = draw(st.lists(st.integers(1, 3), min_size=len(parts), max_size=len(parts)))
    return "".join(word + " " * gap for word, gap in zip(parts, gaps, strict=True))


@given(sentences())
@example("a  b ")
def test_slug_has_no_spaces(text: str) -> None:
    assert " " not in slug(text)


@given(st.text())
def test_slug_is_lower_case(text: str) -> None:
    assert slug(text) == slug(text).lower()


@given(words)
def test_slug_keeps_every_word(parts: list[str]) -> None:
    assume(len(parts) > 1)
    assert slug(" ".join(parts)).split("-") == parts
PY
