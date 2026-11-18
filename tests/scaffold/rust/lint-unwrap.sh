# expect: red Lint
# .unwrap() in library code.
printf '%s\n' '
/// Parses a number.
///
/// # Panics
///
/// When `s` is not a number.
#[must_use]
pub fn parse(s: &str) -> i64 {
    s.parse().unwrap()
}' >> src/lib.rs
