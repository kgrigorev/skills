# expect: red Tests
# pytest.raises with the exception class from a parameter, which the ast check cannot name. It
# is Exception, so it catches the failing assert.
cat >tests/test_param.py <<'PY'
"""Parametrized raises."""

import pytest

from sample_tool.core import slug


@pytest.mark.parametrize("error", [Exception])
def test_slug_keeps_case(error: type[BaseException]) -> None:
    with pytest.raises(error):
        assert slug("A") == "A"
PY
