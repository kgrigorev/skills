# expect: red Lint
# A public function without a doc comment.
printf '\n#[must_use]\npub fn undocumented() -> u8 {\n    1\n}\n' >> src/lib.rs
