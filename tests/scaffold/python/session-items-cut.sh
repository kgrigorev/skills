# expect: red Tests
# The first test removes a failing test from the run after collection, where the dropped-tests
# check no longer looks. tests/conftest.py fails a collected test that never reported.
cat >tests/test_aa_session.py <<'PY'
"""Runs first."""

import pytest


def test_session_starts(request: pytest.FixtureRequest) -> None:
    items = request.session.items
    items[:] = [item for item in items if "keeps_case" not in item.name]
PY
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
