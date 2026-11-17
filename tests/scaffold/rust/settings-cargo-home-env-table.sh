# expect: red Settings files
# env: CARGO_HOME=.cargo-home
# A cargo config outside the project with an [env] table.
mkdir -p .cargo-home
printf '[env]\nPROPTEST_CASES = "0"\n' > .cargo-home/config.toml
