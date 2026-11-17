# expect: red Lint
# env: RUSTC_WORKSPACE_WRAPPER=/usr/bin/env
# A wrapper from the environment. clippy-driver must still run.
printf '\n/// Parses a number.\n///\n/// # Panics\n///\n/// When `s` is not a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().unwrap()\n}\n' >> src/lib.rs
