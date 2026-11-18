# expect: red No switched-off checks
# A macro gets # and [test] as separate tokens and writes the test without its red body.
cat >> tests/sample_tool.rs <<'R'

macro_rules! keep_name {
    ($hash:tt, $attr:tt fn $name:ident() $body:block) => {
        $hash $attr fn $name() {}
    };
}

keep_name! { #, [test] fn red_body_dropped() { assert_eq!(1, 2); } }
R
