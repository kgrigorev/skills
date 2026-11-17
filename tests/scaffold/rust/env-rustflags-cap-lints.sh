# expect: red Lint
# env: RUSTFLAGS=--cap-lints=allow
# RUSTFLAGS from the caller would cap every lint.
printf '\n/// Parses a number.\n///\n/// # Panics\n///\n/// When `s` is not a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().unwrap()\n}\n' >> src/lib.rs
