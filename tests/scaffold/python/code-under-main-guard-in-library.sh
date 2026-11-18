# expect: red Types
# A type error under a `__name__` guard, where no test runs it.
cat >>src/sample_tool/core.py <<'PY'


if __name__ == "__main__":
    slug(1)
PY
