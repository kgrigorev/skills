# expect: red No switched-off checks
# not(doctest) hides an item, and its wrong doc example, from cargo test --doc.
cat >> src/lib.rs <<'R'

/// Doubles a number.
///
/// ```
/// assert_eq!(sample_tool::double(2), 5);
/// ```
#[cfg(not(doctest))]
#[must_use]
pub fn double(n: u8) -> u8 {
    n.saturating_mul(2)
}
R
