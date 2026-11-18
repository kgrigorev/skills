# expect: green
# Ordinary attributes: derive, non_exhaustive, inline, must_use, cfg(test), and match arms with _.
cat >> src/lib.rs <<'R'

/// How a word count is shown.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
#[non_exhaustive]
pub enum Style {
    /// Digits only.
    #[default]
    Plain,
    /// Digits and a unit.
    Long,
}

/// Shows `count` in `style`.
#[inline]
#[must_use]
pub fn show(count: usize, style: Style) -> String {
    match style {
        Style::Plain => count.to_string(),
        Style::Long => match count {
            1 => String::from("1 word"),
            _ => format!("{count} words"),
        },
    }
}

#[cfg(test)]
mod style_tests {
    use super::{Style, show};

    #[test]
    fn long_style_names_the_unit() {
        assert_eq!(show(1, Style::Long), "1 word");
        assert_eq!(show(2, Style::Long), "2 words");
    }

    #[test]
    fn plain_is_the_default() {
        assert_eq!(show(3, Style::default()), "3");
    }
}
R
mise exec -- cargo fmt --all
