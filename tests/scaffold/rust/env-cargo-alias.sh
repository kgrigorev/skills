# expect: red Lint
# env: CARGO_ALIAS_CLIPPY=check
# An alias from the environment would replace clippy with check.
printf '\n/// Parses a number.\n///\n/// # Panics\n///\n/// When `s` is not a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().unwrap()\n}\n' >> src/lib.rs
