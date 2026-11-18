# expect: red Only mise.toml sets the tools
# A .config/mise.toml, which mise also loads.
mkdir -p .config
printf '[env]\nCHECK_UNDER_MISE = "1"\n' >.config/mise.toml
