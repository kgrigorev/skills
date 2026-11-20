# expect: green
# The plain cfg(doctest) and cfg_attr(debug_assertions, ...) forms are fine: the first runs the
# README's Rust examples as doc tests, the second adds a derive in debug builds.
cat >> src/lib.rs <<'R'

/// The README's Rust examples, run as doc tests.
#[cfg(doctest)]
#[doc = include_str!("../README.md")]
pub struct ReadmeDoctests;

/// A point.
#[cfg_attr(debug_assertions, derive(Debug))]
pub struct Point {
    /// Across.
    pub x: i32,
}
R
