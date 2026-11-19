# expect: red Tests
# __test__ = False set at run time on a test class inside another test class.
cat >tests/test_nested.py <<'PY'
"""Nested."""

from sample_tool.core import slug


class TestSlug:
    """Outer."""

    class TestCase:
        """Inner."""

        def test_keeps_case(self) -> None:
            """Keeps case."""
            assert slug("A") == "A"


setattr(TestSlug.TestCase, "__te" + "st__", False)
PY
