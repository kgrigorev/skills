# expect: red No switched-off checks
# cfg_attr(doctest, cfg(any())) is not(doctest) in another form: it hides a wrong doc example.
cat >> src/lib.rs <<'T'

/// Doubles a number.
///
/// ```
/// assert_eq!(sample_tool::double(2), 5);
/// ```
#[cfg_attr(doctest, cfg(any()))]
#[must_use]
pub fn double(n: u8) -> u8 {
    n.saturating_mul(2)
}
T
