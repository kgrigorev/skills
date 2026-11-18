# expect: red No switched-off checks
# pytest 9 reads pytest.toml before pyproject.toml: strict mode and the warning filter go.
cat >pytest.toml <<'TOML'
[pytest]
testpaths = ["tests"]
addopts = ["--import-mode=importlib"]
TOML
cat >tests/test_old.py <<'PY'
"""Tests that warn."""

import warnings

from sample_tool.core import slug


def test_warns() -> None:
    warnings.warn("ignored now", UserWarning, stacklevel=1)
    assert slug("a") == "a"
PY
