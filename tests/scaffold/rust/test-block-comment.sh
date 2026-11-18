# expect: red Test
# A block comment after #[test] hides the cfg'd test from the "never run" scan.
printf '\n#[cfg(miri)]\n#[test] /* slow */\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
