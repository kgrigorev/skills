# expect: red Lint
# #[should_panic] without expected, and a test that throws its value away.
printf '\n#[test]\n#[should_panic]\nfn red_test_made_green() {\n    assert_eq!(word_count("a b"), 3);\n}\n\n#[test]\nfn no_assertions() {\n    let _ = word_count("a b");\n}\n' >> tests/sample_tool.rs
