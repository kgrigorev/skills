# expect: red Tool versions
# .config/mise/config.toml is another mise config file in the repository.
mkdir -p .config/mise
printf '[env]\nLSAN_OPTIONS = "detect_leaks=0"\n' >.config/mise/config.toml
