# expect: green
# Generics, a trait with a default method, an iterator adapter, lifetimes, char_indices and a
# property test of a new function.
cat >> src/lib.rs <<'R'

/// Something with a length in words.
pub trait Wordy {
    /// The text to count.
    fn text(&self) -> &str;

    /// The number of words in the text.
    fn words(&self) -> usize {
        word_count(self.text())
    }
}

impl Wordy for str {
    fn text(&self) -> &str {
        self
    }
}

impl Wordy for String {
    fn text(&self) -> &str {
        self
    }
}

/// The longest item in `items`, by word count. The first one wins a tie.
pub fn longest<T>(items: &[T]) -> Option<&T>
where
    T: Wordy,
{
    items.iter().fold(None, |best: Option<&T>, item| match best {
        Some(best) if best.words() >= item.words() => Some(best),
        _ => Some(item),
    })
}

/// The byte offsets where words start.
pub fn word_starts(text: &str) -> impl Iterator<Item = usize> + '_ {
    text.char_indices()
        .scan(true, |after_space, (index, ch)| {
            let start = *after_space && !ch.is_whitespace();
            *after_space = ch.is_whitespace();
            Some(start.then_some(index))
        })
        .flatten()
}
R
cat >> tests/sample_tool.rs <<'R'

proptest! {
    /// There is one start per word.
    #[test]
    fn one_start_per_word(text in "\\PC*") {
        prop_assert_eq!(sample_tool::word_starts(&text).count(), word_count(&text));
    }
}

#[test]
fn longest_picks_the_most_words() {
    let items = vec![String::from("a b"), String::from("a b c"), String::from("x y z")];
    assert_eq!(sample_tool::longest(&items), Some(&items[1]));
    assert_eq!(sample_tool::longest::<String>(&[]), None);
}
R
mise exec -- cargo fmt --all
