# expect: red Lint
# A test behind a feature that Cargo.toml never declares: the unexpected_cfgs lint.
printf '\n#[cfg(feature = "never")]\n#[test]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
