# expect: red Test
# #[ignore] does not hide a red test: ignored tests run too.
printf '\n#[test]\n#[ignore = "slow"]\nfn ignored_red() {\n    assert_eq!(word_count("a"), 2);\n}\n' >> tests/sample_tool.rs
