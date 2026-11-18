# expect: red Lint
# Only the let _ in a test.
printf '\n#[test]\nfn no_assertions() {\n    let _ = word_count("a b");\n}\n' >> tests/sample_tool.rs
