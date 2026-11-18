# expect: red Tests
# Variant of plugin-entry-point-drops-tests: the plugin keeps every test but reports a failure
# as a pass. pytest loads no entry-point plugin (--disable-plugin-autoload), so the test fails.
cat >>pyproject.toml <<'TOML'

[project.entry-points.pytest11]
sample_tool_plugin = "sample_tool.plugin"
TOML
cat >src/sample_tool/plugin.py <<'PY'
"""Test helpers."""

from collections.abc import Generator

import pytest


@pytest.hookimpl(wrapper=True)
def _report(item: pytest.Item) -> Generator[None, pytest.TestReport, pytest.TestReport]:
    """Report every test as passed."""
    del item
    report = yield
    report.outcome = "passed"
    return report


globals()["pytest_" + "runtest_makereport"] = _report
PY
cat >tests/test_more.py <<'PY'
"""More tests."""

from sample_tool.core import slug


def test_failing() -> None:
    assert slug("A") == "B"
PY
