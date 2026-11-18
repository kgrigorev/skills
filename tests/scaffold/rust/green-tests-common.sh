# expect: green
# Shared test helpers in tests/common/mod.rs, used by two test files; cfg_attr(miri, ignore).
mkdir -p tests/common
cat > tests/common/mod.rs <<'R'
//! Helpers shared by the integration tests.

/// Text with `n` words.
pub fn words(n: usize) -> String {
    vec!["w"; n].join(" ")
}
R
cat > tests/counts.rs <<'R'
//! Word counts of generated text.

mod common;

use sample_tool::word_count;

#[test]
fn generated_text_has_the_asked_words() {
    for n in [0, 1, 7, 100] {
        assert_eq!(word_count(&common::words(n)), n, "for {n} words");
    }
}

#[test]
#[cfg_attr(miri, ignore)]
fn a_large_text() {
    assert_eq!(word_count(&common::words(100_000)), 100_000);
}
R
cat > tests/banner.rs <<'R'
//! The banner next to generated text.

mod common;

#[test]
fn banner_words_add_up() {
    let text = format!("{} {}", sample_tool::banner(), common::words(3));
    assert_eq!(sample_tool::word_count(&text), sample_tool::word_count(&sample_tool::banner()) + 3);
}
R
mise exec -- cargo fmt --all
