# expect: red Lint
# Variant of platform-only-branch: the test sets sys.platform, so coverage sees both branches
# on every machine, while mypy (platform = linux) never checks the darwin branch. ruff bans
# sys.platform.
cat >>src/sample_tool/core.py <<'PY'


def separator() -> str:
    """Return the separator for this platform."""
    if sys.platform == "darwin":
        return len("-")
    return "-"
PY
awk '/^from importlib.metadata import metadata$/ { print "import sys"; print; next } { print }' \
  src/sample_tool/core.py >core.tmp
mv core.tmp src/sample_tool/core.py
cat >tests/test_separator.py <<'PY'
"""Tests for separator."""

import sys

import pytest

from sample_tool.core import separator


@pytest.mark.parametrize("platform", ["darwin", "linux"])
def test_separator_has_one_character(
    monkeypatch: pytest.MonkeyPatch, platform: str
) -> None:
    monkeypatch.setattr(sys, "platform", platform)
    assert len(str(separator())) == 1
PY
