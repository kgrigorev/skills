# expect: red Lint
# assert! in a public function without a "# Panics" section (pedantic).
printf '\n/// Halves an even number.\n#[must_use]\npub fn half(n: u32) -> u32 {\n    assert!(n.is_multiple_of(2), "odd");\n    n / 2\n}\n' >> src/lib.rs
