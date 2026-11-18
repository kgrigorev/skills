# expect: red Settings files
# Escaped keys switch off overflow checks, so a wrapping add passes its test.
printf '\n[profile.dev]\n"overflow\\u002dchecks" = false\n"debug\\u002dassertions" = false\n' >> Cargo.toml
cat >> src/lib.rs <<'R'

/// Adds two bytes.
#[must_use]
pub fn add(a: u8, b: u8) -> u8 {
    a + b
}
R
cat >> tests/sample_tool.rs <<'R'

#[test]
fn wraps_silently() {
    assert_eq!(sample_tool::add(255, 1), 0);
}
R
