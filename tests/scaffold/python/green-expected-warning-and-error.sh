# expect: green
# The library warns on purpose; the tests expect the warning with pytest.warns and the error
# with pytest.raises. A warning fails the run only when no test expects it.
cat >src/sample_tool/legacy.py <<'PY'
"""The old name of slug, kept for one release."""

import warnings

from sample_tool.core import slug


def make_slug(text: object) -> str:
    """Return slug(text). Deprecated: call slug.

    Raises:
        TypeError: text is not a str.
    """
    if not isinstance(text, str):
        msg = f"text must be a str, not {type(text).__name__}"
        raise TypeError(msg)
    warnings.warn("make_slug is deprecated", DeprecationWarning, stacklevel=2)
    return slug(text)
PY
cat >tests/test_legacy.py <<'PY'
"""Tests for the old name of slug."""

import pytest

from sample_tool.legacy import make_slug


def test_make_slug_warns_and_still_works() -> None:
    with pytest.warns(DeprecationWarning, match="deprecated"):
        assert make_slug("A b") == "a-b"


def test_make_slug_rejects_bytes() -> None:
    with pytest.raises(TypeError, match="must be a str, not bytes"):
        make_slug(b"A b")
PY
