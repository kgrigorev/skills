# expect: green
# A new test file with properties, a helper returning TestCaseError, and a regular test.
cat > tests/word_count_props.rs <<'R'
//! Properties of `word_count`.

use proptest::prelude::*;
use proptest::test_runner::TestCaseError;
use sample_tool::word_count;

fn check_repeat(word: &str, times: usize) -> Result<(), TestCaseError> {
    let text = vec![word; times].join(" ");
    prop_assert_eq!(word_count(&text), times);
    Ok(())
}

proptest! {
    /// Repeating one word n times gives n words.
    #[test]
    fn repeated_words_are_counted(word in "[a-z]{1,8}", times in 0usize..20) {
        check_repeat(&word, times)?;
    }

    /// White space alone holds no words.
    #[test]
    fn white_space_has_no_words(text in "[ \t\n]*") {
        prop_assert_eq!(word_count(&text), 0);
    }
}

#[test]
fn empty_text_has_no_words() {
    assert_eq!(word_count(""), 0);
}
R
mise exec -- cargo fmt --all
