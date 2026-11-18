# expect: red No switched-off checks
# The hidden variant of pytest.toml.
cat >.pytest.toml <<'TOML'
[pytest]
testpaths = ["tests"]
TOML
