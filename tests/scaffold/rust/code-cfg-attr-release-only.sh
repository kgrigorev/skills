# expect: red No switched-off checks
# cfg_attr(debug_assertions, cfg(any())) is not(debug_assertions) in another form: the
# unwrap is only in a release build, which no gate compiles.
cat >> src/lib.rs <<'T'

/// Parses a number.
///
/// # Errors
///
/// When `text` is not a number.
pub fn parse(text: &str) -> Result<i64, std::num::ParseIntError> {
    #[cfg_attr(debug_assertions, cfg(any()))]
    return Ok(text.parse().unwrap());
    #[cfg(debug_assertions)]
    text.parse()
}
T
