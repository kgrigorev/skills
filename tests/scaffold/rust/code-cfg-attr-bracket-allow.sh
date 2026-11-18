# expect: red No switched-off checks
# A ] inside cfg_attr before the allow hides it from the scan.
cat >> src/lib.rs <<'R'

#[cfg_attr(all(), doc = "`a[0]` is safe", allow(clippy::unwrap_used))]
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
