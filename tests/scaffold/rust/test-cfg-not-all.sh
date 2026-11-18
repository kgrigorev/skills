# expect: red Test
# Always-false cfgs hide red tests.
printf '\n#[cfg(not(all()))]\n#[test]\nfn red_test_hidden() {\n    assert_eq!(1, 2);\n}\n\n#[cfg(miri)]\n#[test]\nfn red_test_hidden_miri() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
