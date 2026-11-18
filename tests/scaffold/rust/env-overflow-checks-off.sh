# expect: red Test
# env: CARGO_PROFILE_DEV_OVERFLOW_CHECKS=false
# A profile variable would make a wrapping add pass its test.
printf '\n/// Adds two bytes.\n#[must_use]\npub fn add(a: u8, b: u8) -> u8 {\n    a + b\n}\n' >> src/lib.rs
printf '\n#[test]\nfn wraps_silently() {\n    assert_eq!(sample_tool::add(255, 1), 0);\n}\n' >> tests/sample_tool.rs
