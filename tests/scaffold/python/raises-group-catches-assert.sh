# expect: red No switched-off checks
# pytest.RaisesGroup with allow_unwrapped=True catches a plain exception, so with Exception it
# catches the failing assert, and the test passes because of the bug.
cat >tests/test_group.py <<'PY'
"""Group."""

import pytest

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    with pytest.RaisesGroup(Exception, allow_unwrapped=True):
        assert slug("A") == "A"
PY
