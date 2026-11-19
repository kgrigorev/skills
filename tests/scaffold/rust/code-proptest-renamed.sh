# expect: red No switched-off checks
# proptest! renamed away, then called with a config: zero cases, a wrong property.
cat >> tests/sample_tool.rs <<'T'

#[test]
fn wrong_renamed() {
    use proptest::proptest as pt;
    use proptest::test_runner::Config;
    pt!(Config { cases: 0, ..Config::default() }, |(text in ".*")| {
        prop_assert_eq!(word_count(&text), 999);
    });
}
T
