# expect: red Tests
# The guard's block holds main() and, after a blank line, untested code. Coverage skips the whole
# block when the exclusion pattern matches its first lines.
cat >>src/sample_tool/core.py <<'PY'


def main() -> None:
    """Run."""


if __name__ == "__main__":
    main()

    if slug("x") == "y":
        raise SystemExit(1)
PY
