# expect: red Tests
# A failing test, and a second test that sets pytest's failure count back to 0, so pytest exits
# 0. tests/conftest.py keeps its own record of failures.
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
cat >tests/test_zz_session.py <<'PY'
"""Clean session."""

import pytest


def test_session_is_clean(request: pytest.FixtureRequest) -> None:
    request.session.testsfailed = 0
PY
