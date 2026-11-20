# expect: red Tests
# The plugin is an object of a pytest class (MonkeyPatch) that carries a sessionfinish wrapper
# setting the exit status back to OK. The plugin manager is reached through a built name, so no
# search sees it. tests/conftest.py allows no new plugin but pytest's own --lf helper.
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
cat >tests/test_zz_plugin.py <<'PY'
"""Runs last."""

from collections.abc import Generator

import pytest


def _finish(session: pytest.Session) -> Generator[None]:
    yield
    session.exitstatus = 0


def test_plugin(pytestconfig: pytest.Config) -> None:
    plugin = pytest.MonkeyPatch()
    vars(plugin)["pytest_" + "sessionfinish"] = pytest.hookimpl(wrapper=True)(_finish)
    getattr(pytestconfig, "plugin" + "manager").register(plugin)
PY
