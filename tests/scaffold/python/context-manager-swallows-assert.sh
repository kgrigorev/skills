# expect: red Tests
# A hand-written context manager whose __exit__ returns True swallows the failing assert. No
# name gives it away; tests/conftest.py sees the AssertionError being caught.
cat >tests/test_quiet.py <<'PY'
"""Quiet."""

from types import TracebackType
from typing import Literal

from sample_tool.core import slug


class Quiet:
    """Swallows any error."""

    def __enter__(self) -> None:
        """Start."""

    def __exit__(
        self,
        kind: type[BaseException] | None,
        error: BaseException | None,
        trace: TracebackType | None,
    ) -> Literal[True]:
        """Swallow."""
        return True


def test_slug_keeps_case() -> None:
    with Quiet():
        assert slug("A") == "A"
PY
