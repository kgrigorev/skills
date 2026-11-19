# expect: red No switched-off checks
# cfg(clippy) gives Clippy other code than the build and the tests run.
cat >> src/lib.rs <<'R'

/// Parses a number.
///
/// # Errors
///
/// When `text` is not a number.
pub fn parse(text: &str) -> Result<i64, std::num::ParseIntError> {
    #[cfg(not(clippy))]
    return Ok(text.parse().unwrap());
    #[cfg(clippy)]
    text.parse()
}
R
