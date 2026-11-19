# expect: red No switched-off checks
# The closure form of proptest! takes a config as its first argument: zero cases, a wrong
# property.
cat >> tests/sample_tool.rs <<'R'

#[test]
fn wrong_closure() {
    use proptest::test_runner::Config;
    proptest!(Config { cases: 0, ..Config::default() }, |(text in ".*")| {
        prop_assert_eq!(word_count(&text), 999);
    });
}
R
