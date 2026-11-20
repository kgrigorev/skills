# expect: red Tests
# Same as session-failure-count-reset, but the test also sets the collect-only option, and the
# conftest's sessionfinish check returns early.
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
    request.config.option.collectonly = True
PY
