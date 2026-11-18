# expect: red No switched-off checks
# pytest_plugins loads a plugin that could change what runs.
cat >tests/test_plugins.py <<'PY'
"""Tests with a plugin."""

from sample_tool.core import slug

pytest_plugins = ["pytester"]


def test_slug() -> None:
    assert slug("A b") == "a-b"
PY
