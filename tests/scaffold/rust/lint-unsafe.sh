# expect: red Lint
# unsafe code is forbidden.
printf '\n/// Reads the first byte.\n#[must_use]\npub fn first(b: &[u8]) -> u8 {\n    unsafe { *b.as_ptr() }\n}\n' >> src/lib.rs
