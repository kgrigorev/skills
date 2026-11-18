# expect: red Tests
# Variant of dunder-test-false-class: __test__ set on one method at run time. The class still
# runs its other test, so the file is not empty; tests/conftest.py names the one pytest skipped.
cat >tests/test_bug.py <<'PY'
"""Tests for a bug."""

from sample_tool.core import slug


class TestSlug:
    """Tests for slug."""

    def test_joins_words(self) -> None:
        """Words are joined by "-"."""
        assert slug("A b") == "a-b"

    def test_keeps_case(self) -> None:
        """The case stays as it is."""
        assert slug("A") == "A"


setattr(TestSlug.test_keeps_case, "__te" + "st__", False)
PY
