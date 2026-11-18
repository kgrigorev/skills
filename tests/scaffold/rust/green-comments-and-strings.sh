# expect: green
# Words the suppression search looks for, in plain comments and in strings.
cat >> src/lib.rs <<'R'

// Lints are never switched off with #[allow(...)] or #[expect(...)] here: fix the cause.
// Doc examples are never marked ```ignore or ```no_run, and `_ = f();` would drop a Result.
// No #[doc(hidden)], #[rustfmt::skip], #[path = "..."] or include!("...") either.

/// Says whether `word` is on the allow list: "allow", "expect" or "ignore".
///
/// ```
/// assert!(sample_tool::allowed("ignore"));
/// assert!(!sample_tool::allowed("hidden"));
/// ```
#[must_use]
pub fn allowed(word: &str) -> bool {
    // The list is short, so a linear search is fine.
    ["allow", "expect", "ignore"].contains(&word)
}

/// Builds a flag such as `--include=src` or `--no_run`.
#[must_use]
pub fn flag(name: &str, value: Option<&str>) -> String {
    match value {
        Some(value) => format!("--{name}={value}"),
        None => format!("--{name}"),
    }
}
R
mise exec -- cargo fmt --all
