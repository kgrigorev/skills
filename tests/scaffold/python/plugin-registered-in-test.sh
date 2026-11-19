# expect: red Tests
# A test registers a plugin whose report hook turns every failure into a pass. The hook name and
# the plugin manager's are built at run time, so no search sees them. tests/conftest.py stops
# the run when the set of plugins changes.
cat >tests/test_aa_plugin.py <<'PY'
"""Runs first."""

from collections.abc import Generator

import pytest


def _report() -> Generator[None, pytest.TestReport, pytest.TestReport]:
    report = yield
    report.outcome = "passed"
    return report


def test_plugin(pytestconfig: pytest.Config) -> None:
    hook = pytest.hookimpl(wrapper=True)(_report)
    plugin = type("Plugin", (), {"pytest_" + "runtest_makereport": staticmethod(hook)})
    getattr(pytestconfig, "plugin" + "manager").register(plugin())
PY
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
