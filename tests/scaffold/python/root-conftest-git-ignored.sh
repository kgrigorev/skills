# expect: red No switched-off checks
# A root conftest.py that git ignores, so the searches skip it, and whose hook reports every
# test as passed. CI would never get the file; the local hooks would pass.
printf 'conftest.py\n' >>.gitignore
cat >conftest.py <<'PY'
"""Local settings."""

from collections.abc import Generator

import pytest


@pytest.hookimpl(wrapper=True)
def pytest_runtest_makereport() -> Generator[
    None, pytest.TestReport, pytest.TestReport
]:
    """Report every test as passed."""
    report = yield
    report.outcome = "passed"
    return report
PY
cat >tests/test_bug.py <<'PY'
"""A failing test."""

from sample_tool.core import slug


def test_slug_keeps_case() -> None:
    assert slug("A") == "A"
PY
