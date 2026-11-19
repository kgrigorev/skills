# expect: red No switched-off checks
# A non-ASCII character literal next to '"'. Read as bytes, the reader paired the quotes wrongly
# and took the #[allow] below for the inside of a string. rustfmt leaves the braces of
# thread_local! as written.
cat >> src/lib.rs <<'R'

thread_local! {
    /// Characters that need quoting.
    pub static QUOTED: [char; 2] = const { ['é','"'] };
}

/// Parses a number.
#[allow(clippy::unwrap_used, clippy::missing_panics_doc)]
#[must_use]
pub fn parse(text: &str) -> i64 {
    text.parse().unwrap()
}

/// The name of the format.
pub const FORMAT: &str = "plain";
R
