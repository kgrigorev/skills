# expect: red No switched-off checks
# A macro writes a passing test in the same module, with the name of the hidden red one.
cat >> tests/sample_tool.rs <<'R'

#[cfg(miri)]
#[test]
fn hidden_red() {
    assert_eq!(1, 2);
}

macro_rules! passing {
    ($name:ident) => {
        #[test]
        fn $name() {}
    };
}

passing!(hidden_red);
R
