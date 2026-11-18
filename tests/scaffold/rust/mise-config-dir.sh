# expect: red Tools
# mise also reads mise/config.toml, which can set variables for every tool.
mkdir -p mise
printf '[env]\nFOO = "1"\n' > mise/config.toml
