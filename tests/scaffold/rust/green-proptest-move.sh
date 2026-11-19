# expect: green
# The closure form of proptest! with move and no config is fine.
cat >> tests/sample_tool.rs <<'T'

#[test]
fn word_count_of_one_word_is_one_moved() {
    let limit = 8;
    proptest!(move |(word in "[a-z]{1,8}")| {
        prop_assert!(word.len() <= limit);
        prop_assert_eq!(word_count(&word), 1);
    });
}
T
