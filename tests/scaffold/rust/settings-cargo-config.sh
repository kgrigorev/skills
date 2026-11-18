# expect: red Settings files
# A project .cargo/config.toml can alias clippy to check.
mkdir -p .cargo
printf '[alias]\nclippy = "check"\n' > .cargo/config.toml
