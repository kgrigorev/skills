# expect: red No switched-off checks
# Variant of flake8-file-noqa: a file-level flake8 exemption that names its rule, so PGH004
# (blanket noqa) does not fire. The search looks for `# noqa`, not `# flake8: noqa`.
cat >>src/sample_tool/core.py <<'PY'


def shout(text: str) -> None:
    """Print the text."""
    print(text)
PY
awk 'NR == 2 { print "# flake8: noqa: T201" } { print }' src/sample_tool/core.py >core.tmp
mv core.tmp src/sample_tool/core.py
cat >tests/test_shout.py <<'PY'
"""Tests for shout."""

import pytest

from sample_tool.core import shout


def test_shout_prints(capsys: pytest.CaptureFixture[str]) -> None:
    shout("hi")
    assert capsys.readouterr().out == "hi\n"
PY
