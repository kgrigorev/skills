# expect: green
# File names with digits, dashes and a nested module folder.
mkdir -p src/text
printf '//! Text helpers.\n\npub mod split_v2;\n' > src/text/mod.rs
cat > src/text/split_v2.rs <<'R'
//! Splitting, version 2.

/// Splits `text` at commas and trims each part.
#[must_use]
pub fn split_commas(text: &str) -> Vec<&str> {
    text.split(',').map(str::trim).filter(|part| !part.is_empty()).collect()
}
R
printf '\npub mod text;\n' >> src/lib.rs
cat > tests/split-v2_edge-cases.rs <<'R'
//! Edge cases for `split_commas`.

use sample_tool::text::split_v2::split_commas;

#[test]
fn empty_parts_are_dropped() {
    assert_eq!(split_commas("a,, b ,"), vec!["a", "b"]);
}
R
mise exec -- cargo fmt --all
