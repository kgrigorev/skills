# expect: red Dependencies
# An orphan .rs file that would compile, with a red test in an orphan test folder.
printf '//! Parser.\n\n/// Parses.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().unwrap_or(0)\n}\n' > src/parser.rs
mkdir -p tests/unit
printf '//! Unit.\n\n#[test]\nfn fails() {\n    assert_eq!(1, 2);\n}\n' > tests/unit/parse.rs
