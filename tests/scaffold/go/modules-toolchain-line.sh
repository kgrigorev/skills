# expect: red Lint
# A toolchain line in go.mod, which mise.toml pins instead (gomoddirectives).
printf '\ntoolchain go1.27.4\n' >>go.mod
