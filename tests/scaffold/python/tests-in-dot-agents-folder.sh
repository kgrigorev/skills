# expect: red Lint
# ruff skips only the .agents folder at the root ("./.agents"), so it lints tests/.agents/, which
# pytest collects. The file has a lint error (unused import) and a banned API.
mkdir -p tests/.agents
cat >tests/.agents/test_hidden.py <<'PY'
"""Tests in a folder named .agents."""

import os
from contextlib import suppress as quiet

from sample_tool.core import slug


def test_slug() -> None:
    with quiet(ValueError):
        assert slug("A") == "a"
PY
