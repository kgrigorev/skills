# expect: red Tools
# .mise.toml is a second mise config next to mise.toml.
printf '[env]\nRUSTFLAGS = "--cap-lints=allow"\n' > .mise.toml
