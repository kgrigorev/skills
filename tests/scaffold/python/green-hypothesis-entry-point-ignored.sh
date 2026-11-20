# expect: green
# A [project.entry-points.hypothesis] hook runs when hypothesis is imported, before
# tests/conftest.py, and could change its settings. scripts/check sets HYPOTHESIS_NO_PLUGINS, so
# this hook, which would break every run, never runs.
perl -0pi -e 's/\[dependency-groups\]/[project.entry-points.hypothesis]\nhook = "sample_tool.hook:setup"\n\n[dependency-groups]/' pyproject.toml
grep -q 'entry-points.hypothesis' pyproject.toml
cat >src/sample_tool/hook.py <<'PY'
"""A Hypothesis plugin hook."""


def setup() -> None:
    """Refuse to load."""
    msg = "the hypothesis entry point ran"
    raise RuntimeError(msg)
PY
cat >tests/test_hook.py <<'PY'
"""Tests."""

import pytest

from sample_tool.hook import setup


def test_setup_refuses() -> None:
    with pytest.raises(RuntimeError, match="entry point ran"):
        setup()
PY
