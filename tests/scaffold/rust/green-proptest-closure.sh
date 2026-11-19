# expect: green
# The closure form of proptest! without a config is fine.
cat >> tests/sample_tool.rs <<'R'

#[test]
fn word_count_of_one_word_is_one() {
    proptest!(|(word in "[a-z]{1,8}")| {
        prop_assert_eq!(word_count(&word), 1);
    });
}
R
