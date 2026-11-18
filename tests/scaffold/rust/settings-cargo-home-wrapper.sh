# expect: red Settings files
# env: CARGO_HOME=.cargo-home
# A cargo config outside the project wraps rustc, in an inline table with quoted keys.
mkdir -p .cargo-home
printf '"build" = { "rustc-wrapper" = "/usr/bin/env" }\n' > .cargo-home/config.toml
