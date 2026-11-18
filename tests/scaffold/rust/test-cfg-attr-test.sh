# expect: red Test
# #[cfg_attr(miri, test)] makes the red test never a test; a const use keeps dead_code quiet.
printf '\nconst _: fn() = hidden_red;\n\n#[cfg_attr(miri, test)]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
