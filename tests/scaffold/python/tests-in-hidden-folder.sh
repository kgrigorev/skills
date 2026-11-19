# expect: red No switched-off checks
# mypy skips folders whose names start with a dot, but pytest collects them: the type error
# below would never be checked. The layout check rejects such folders.
mkdir -p tests/.hidden
cat >tests/.hidden/test_hidden.py <<'PY'
"""Hidden."""

from sample_tool.core import slug


def test_slug() -> None:
    value: int = slug("A")
    assert value
PY
