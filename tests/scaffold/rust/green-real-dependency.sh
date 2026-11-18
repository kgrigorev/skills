# expect: green
# A real crates.io dependency used in the library, added offline from the local cache.
mise exec -- cargo add bitflags@2 --offline
cat >> src/lib.rs <<'R'

bitflags::bitflags! {
    /// What a count includes.
    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    pub struct Counted: u8 {
        /// Words.
        const WORDS = 1;
        /// Lines.
        const LINES = 1 << 1;
    }
}

/// Counts the parts of `text` that `what` names.
#[must_use]
pub fn count(text: &str, what: Counted) -> usize {
    let mut total = 0;
    if what.contains(Counted::WORDS) {
        total += word_count(text);
    }
    if what.contains(Counted::LINES) {
        total += text.lines().count();
    }
    total
}
R
cat >> tests/sample_tool.rs <<'R'

#[test]
fn counts_words_and_lines() {
    use sample_tool::{Counted, count};
    assert_eq!(count("a b\nc", Counted::WORDS | Counted::LINES), 5);
}
R
mise exec -- cargo fmt --all
