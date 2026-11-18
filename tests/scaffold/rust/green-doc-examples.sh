# expect: green
# Doc examples: compile_fail, text blocks, and a hidden setup line.
cat >> src/lib.rs <<'R'

/// Returns the sign of `n` as a word.
///
/// ```compile_fail
/// let n: u32 = sample_tool::sign_word(-1);
/// ```
///
/// The output looks like this:
///
/// ```text
/// negative
/// ```
///
/// ```
/// # use sample_tool::sign_word;
/// assert_eq!(sign_word(-3), "negative");
/// ```
#[must_use]
pub fn sign_word(n: i64) -> &'static str {
    match n {
        0 => "zero",
        _ if n < 0 => "negative",
        _ => "positive",
    }
}
R
mise exec -- cargo fmt --all
