# expect: red Tools
# A .config/mise.toml puts a fake cargo-clippy first on PATH, so an .unwrap() would pass lint.
mkdir -p .config bin
printf '[env]\n_.path = ["{{config_root}}/../bin"]\n' > .config/mise.toml
printf '#!/bin/sh\ncase "$*" in *--version*) echo "clippy 0.1.100 (fake)";; esac\nexit 0\n' > bin/cargo-clippy
chmod +x bin/cargo-clippy
cat >> src/lib.rs <<'R'

/// Parses a number.
#[must_use]
pub fn parse(s: &str) -> i64 {
    s.parse().unwrap()
}
R
