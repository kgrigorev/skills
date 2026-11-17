# expect: red No switched-off checks
# A cfg_attr(allow) that rustfmt splits over lines.
cat >> src/lib.rs <<'R'

/// Parses a number.
///
/// # Panics
///
/// When `s` is not a number.
#[cfg_attr(all(not(target_os = "windows"), not(target_os = "freebsd"), not(target_os = "netbsd")), allow(clippy::unwrap_used))]
#[must_use]
pub fn parse(s: &str) -> i64 {
    s.parse().unwrap()
}
R
mise exec -- cargo fmt --all
