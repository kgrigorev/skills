# expect: red No switched-off checks
# proptest's Config through the test_runner path, with zero cases and a wrong property.
cat >> tests/sample_tool.rs <<'R'

proptest! {
    #![proptest_config(proptest::test_runner::Config { cases: 0, ..Default::default() })]
    #[test]
    fn wrong(text in ".*") {
        prop_assert_eq!(word_count(&text), 999);
    }
}
R
