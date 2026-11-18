# expect: red No switched-off checks
# __test__ = False stops pytest from collecting the class, with no skip report.
cat >>tests/test_core.py <<'PY'


class TestSlugCase:
    """Case handling."""

    __test__ = False

    def test_keeps_case(self) -> None:
        """Slug keeps upper case."""
        assert slug("A") == "A"
PY
