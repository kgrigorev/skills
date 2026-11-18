# expect: red Lint
# A cast that can truncate (pedantic).
printf '\n/// Narrows a count.\n#[must_use]\npub fn narrow(n: u64) -> u8 {\n    n as u8\n}\n' >> src/lib.rs
