# expect: red Tools
# A .config/mise/config.toml file, which mise also reads.
mkdir -p .config/mise
printf '[env]\nGOFLAGS = "-tags=x"\n' >.config/mise/config.toml
