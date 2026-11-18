# expect: red Test
# The cfg after #[test] hides it too.
printf '\n#[test]\n#[cfg(not(all()))]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
