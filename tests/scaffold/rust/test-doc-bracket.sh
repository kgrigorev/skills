# expect: red Test
# An attribute with ] in a string between #[test] and fn breaks the scan regex.
printf '\n#[cfg(miri)]\n#[test]\n#[doc = "see [1]"]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
