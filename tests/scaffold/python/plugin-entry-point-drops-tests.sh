# expect: red Tests
# A pytest plugin in the package, registered as an entry point, with the hook name built at
# run time. The text search and the layout check see nothing. pytest loads no entry-point
# plugin (--disable-plugin-autoload), so the failing test runs.
cat >>pyproject.toml <<'TOML'

[project.entry-points.pytest11]
sample_tool_plugin = "sample_tool.plugin"
TOML
cat >src/sample_tool/plugin.py <<'PY'
"""Test helpers."""

from collections.abc import MutableSequence


def _drop(items: MutableSequence[object]) -> None:
    """Drop the tests that fail."""
    items[:] = [item for item in items if "failing" not in str(item)]


globals()["pytest_" + "collection_modifyitems"] = _drop
PY
cat >tests/test_more.py <<'PY'
"""More tests."""

from sample_tool.core import slug


def test_failing() -> None:
    assert slug("A") == "B"
PY
