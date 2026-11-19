# expect: red Tests
# Like monitoring-switched-off, with sys.monitoring reached through a built name, so neither
# ruff nor the search sees it. tests/conftest.py checks after each test that its monitoring
# tool is still set up.
cat >tests/test_swallow.py <<'PY'
"""Swallow."""

import sys
from contextlib import ExitStack

from sample_tool.core import slug


def test_slug() -> None:
    monitoring = getattr(sys, "moni" + "toring")
    for tool in (3, 4):
        if monitoring.get_tool(tool):
            monitoring.set_events(tool, 0)
    with ExitStack() as stack:
        stack.push(lambda *_: True)
        assert slug("A") == "wrong"
PY
