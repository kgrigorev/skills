# expect: green
# Non-ASCII text in character literals, strings, comments and a test name. The reader decodes
# UTF-8, so each literal is one character and the test name matches nextest's list.
cat >> src/lib.rs <<'R'

/// Whether `c` is a German umlaut. Für Größe: ä, ö, ü.
#[must_use]
pub fn is_umlaut(c: char) -> bool {
    matches!(c, 'ä' | 'ö' | 'ü' | 'Ä' | 'Ö' | 'Ü')
}

#[cfg(test)]
mod umlaut_tests {
    use super::is_umlaut;

    #[test]
    fn größe_has_one_umlaut() {
        assert_eq!("Größe".chars().filter(|&c| is_umlaut(c)).count(), 1);
        assert!(!is_umlaut('"'));
        assert!(!is_umlaut('é'));
    }
}
R
