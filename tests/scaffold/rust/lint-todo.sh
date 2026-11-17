# expect: red Lint
# Unfinished code.
printf '\n/// Not done.\n#[must_use]\npub fn later() -> u8 {\n    todo!()\n}\n' >> src/lib.rs
