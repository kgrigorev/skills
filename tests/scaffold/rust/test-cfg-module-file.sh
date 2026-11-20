# expect: red Test
# A module file behind a cfg that is never true: no test binary compiles its red test.
printf '\n#[cfg(miri)]\nmod hidden;\n' >> src/lib.rs
printf '//! Hidden.\n\n#[test]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n' > src/hidden.rs
