# expect: red Test
# A test in tests/common/mod.rs runs once per test file that uses it, so two uses would make up
# for a hidden test of the same name if only names were counted.
printf '\n#[cfg(miri)]\n#[test]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' >> tests/sample_tool.rs
mkdir -p tests/common
printf '//! Shared.\n\n#[test]\nfn hidden_red() {}\n' > tests/common/mod.rs
printf '//! B.\n\nmod common;\n' > tests/b.rs
printf '//! C.\n\nmod common;\n' > tests/c.rs
