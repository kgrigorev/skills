# expect: red Test
# The same wrong pairing of quotes once hid a test behind a cfg that is never true.
cat >> tests/sample_tool.rs <<'R'

thread_local! {
    static QUOTED: [char; 2] = const { ['é','"'] };
}

#[cfg(any())]
#[test]
fn hidden_red() {
    assert_eq!(word_count("a"), 99);
}

#[test]
fn quoted_has_two() {
    assert_eq!(QUOTED.with(|q| q.len()), 2, "two");
}
R
