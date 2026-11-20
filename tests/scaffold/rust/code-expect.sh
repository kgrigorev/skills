# expect: red No switched-off checks
# #[expect] with a reason.
cat >> src/lib.rs <<'R'

#[expect(clippy::unwrap_used, reason = "the input is always a number")]
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
