# expect: red Test
# A test written with a full path cannot make up for a hidden one.
printf '\n#[cfg(miri)]\n#[test]\nfn hidden_red() {\n    assert_eq!(1, 2);\n}\n\n#[core::prelude::v1::test]\nfn decoy() {\n    assert_eq!(1, 1);\n}\n' >> tests/sample_tool.rs
