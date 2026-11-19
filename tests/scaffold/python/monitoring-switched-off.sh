# expect: red Lint
# The test switches off the conftest's sys.monitoring tool (public API), then swallows its
# failing assert with ExitStack.
cat >tests/test_swallow.py <<'PY'
"""Swallow."""

import sys
from contextlib import ExitStack

from sample_tool.core import slug


def test_slug() -> None:
    for tool in (3, 4):
        if sys.monitoring.get_tool(tool):
            sys.monitoring.set_events(tool, 0)
    with ExitStack() as stack:
        stack.push(lambda *_: True)
        assert slug("A") == "wrong"
PY
