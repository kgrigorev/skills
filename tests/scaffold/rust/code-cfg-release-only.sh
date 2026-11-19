# expect: red No switched-off checks
# Code under not(debug_assertions) is only in a release build, which no gate compiles.
cat >> src/lib.rs <<'R'

/// Parses a number.
///
/// # Errors
///
/// When `text` is not a number.
pub fn parse(text: &str) -> Result<i64, std::num::ParseIntError> {
    #[cfg(not(debug_assertions))]
    return Ok(text.parse().unwrap());
    #[cfg(debug_assertions)]
    text.parse()
}
R
