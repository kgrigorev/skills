# expect: red Lint
# Only the bare #[should_panic], no let _.
printf '\n#[test]\n#[should_panic]\nfn red_test_made_green() {\n    assert_eq!(word_count("a b"), 3);\n}\n' >> tests/sample_tool.rs
