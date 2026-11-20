# expect: red No switched-off checks
# uv.toml takes precedence over [tool.uv] in pyproject.toml: uv only warns, and any uv version
# runs.
printf 'required-version = ">=0.1"\n' >uv.toml
