# expect: green
# Brackets, quotes and comment marks inside string and character literals, lifetimes, and a
# block comment that names a test: the code reader must keep its place and find both tests.
cat >> src/lib.rs <<'R'

/// The characters that open a group.
pub const OPENERS: &str = "{[(";

/// Whether `c` opens a group.
#[must_use]
pub fn opens(c: char) -> bool {
    matches!(c, '{' | '[' | '(')
}

/// A raw string with quotes, a hash and comment marks inside.
#[must_use]
pub fn sample() -> &'static str {
    r#"a "quoted" #[allow(x)] // not a comment /* nor this"#
}

#[cfg(test)]
mod literal_tests {
    use super::{OPENERS, opens, sample};

    #[test]
    fn every_opener_opens() {
        assert!(OPENERS.chars().all(opens));
        assert!(!opens('}'));
        assert!(!opens('\''));
        assert!(!opens('"'));
    }

    /* Not a test: #[test] fn commented_out() {} */
    #[test]
    fn the_sample_keeps_its_marks() {
        assert!(sample().contains("// not a comment"));
        assert_eq!(b'{', 123);
        assert_eq!('\u{7b}', '{');
    }
}
R
mise exec -- cargo fmt --all
