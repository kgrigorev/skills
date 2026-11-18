# expect: red Lint
# .expect() in library code.
printf '\n/// Parses a number.\n///\n/// # Panics\n///\n/// When `s` is not a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().expect("a number")\n}\n' >> src/lib.rs
