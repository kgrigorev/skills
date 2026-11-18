# expect: red No switched-off checks
# mypy prefers mypy.ini over pyproject.toml: no strict mode.
cat >mypy.ini <<'INI'
[mypy]
files = src
INI
