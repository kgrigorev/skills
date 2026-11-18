# expect: red Lint
# `except Exception: pass` hides every error (BLE001, S110).
cat >>src/sample_tool/core.py <<'PY'


def number(text: str) -> int:
    """Read a number, or 0."""
    try:
        return int(text)
    except Exception:
        pass
    return 0
PY
