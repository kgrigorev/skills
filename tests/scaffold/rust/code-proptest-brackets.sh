# expect: red No switched-off checks
# proptest![...] with square brackets takes a config too: zero cases, a wrong property.
cat >> tests/sample_tool.rs <<'T'

#[test]
fn wrong_brackets() {
    use proptest::test_runner::Config;
    proptest![Config { cases: 0, ..Config::default() }, |(text in ".*")| {
        prop_assert_eq!(word_count(&text), 999);
    }];
}
T
