# expect: red No switched-off checks
# An ignored, untracked module: git grep skips it, so its noqa goes unseen, and it exists
# only on this machine, so CI would fail where the local check passed.
printf 'src/sample_tool/hidden.py\n' >>.gitignore
cat >src/sample_tool/hidden.py <<'PY'
"""Hidden."""


def hidden() -> int:
    """Return one."""
    unused = 1  # noqa: F841
    return 1
PY
cat >tests/test_hidden.py <<'PY'
"""Hidden tests."""

from sample_tool.hidden import hidden


def test_hidden() -> None:
    assert hidden() == 1
PY
