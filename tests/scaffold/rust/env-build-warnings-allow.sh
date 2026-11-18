# expect: red Lint
# env: CARGO_BUILD_WARNINGS=allow
# The caller cannot turn warnings back into warnings.
printf '\n#[must_use]\npub fn undocumented() -> u8 {\n    1\n}\n' >> src/lib.rs
