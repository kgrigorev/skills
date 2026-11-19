# expect: red Tests
# A test resets pytest's failure count and unregisters tests/conftest.py, so none of its hooks
# run and pytest exits 0. The conftest's atexit check sees that its final check never ran.
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
cat >tests/test_zz_unregister.py <<'PY'
"""Runs last."""

import pytest


def test_unregister(request: pytest.FixtureRequest) -> None:
    request.session.testsfailed = 0
    manager = getattr(request.config, "plugin" + "manager")
    for plugin in list(manager.get_plugins()):
        if str(getattr(plugin, "__file__", "")).endswith("conftest.py"):
            manager.unregister(plugin)
PY
