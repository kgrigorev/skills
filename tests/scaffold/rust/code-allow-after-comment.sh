# expect: red No switched-off checks
# Plain comment lines are dropped before the search, but the #[allow] after one still counts,
# also inside a multi-line cfg_attr.
cat >> src/lib.rs <<'R'

// The input is always a number.
#[cfg_attr(
    // Every platform.
    all(),
    allow(clippy::unwrap_used)
)]
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
