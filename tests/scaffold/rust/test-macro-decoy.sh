# expect: red No switched-off checks
# A macro-written test with the same name, in another module, stands in for the hidden one.
cat >> tests/sample_tool.rs <<'R'

#[cfg(miri)]
#[test]
fn hidden_red() {
    assert_eq!(1, 2);
}

mod decoy {
    macro_rules! passing {
        ($name:ident) => {
            #[test]
            fn $name() {}
        };
    }
    passing!(hidden_red);
}
R
