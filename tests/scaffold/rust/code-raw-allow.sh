# expect: red No switched-off checks
# The raw identifier r#allow.
cat >> src/lib.rs <<'R'

#[r#allow(clippy::unwrap_used)]
/// Parses a number.
///
/// # Panics
///
/// When `s` is not a number.
#[must_use]
pub fn parse(s: &str) -> i64 {
    s.parse().unwrap()
}
R
