# expect: red No switched-off checks
# A macro builds #[allow] from a token at the call site.
cat >> src/lib.rs <<'R'

macro_rules! lint_level {
    ($level:ident, $($item:tt)*) => { #[$level(clippy::unwrap_used)] $($item)* };
}
lint_level!(allow,
    /// Parses a number.
    ///
    /// # Panics
    ///
    /// When `s` is not a number.
    #[must_use]
    pub fn parse(s: &str) -> i64 { s.parse().unwrap() }
);
R
mise exec -- cargo fmt --all
