# expect: red No switched-off checks
# #[allow] on a function.
cat >> src/lib.rs <<'R'

#[allow(clippy::unwrap_used)]
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
