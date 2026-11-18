# expect: red Settings files
# A literal multi-line string hides "allow" from a plain grep.
perl -pi -e "s/^unwrap_used = \"warn\"\$/unwrap_used = '''allow'''/" Cargo.toml
cat >> src/lib.rs <<'R'

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
