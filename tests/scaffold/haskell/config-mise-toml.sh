# expect: red Pinned tools
# mise also reads .config/mise.toml in the project.
mkdir -p .config
printf '[env]\nHLINT_EXTRA = "1"\n' >.config/mise.toml
