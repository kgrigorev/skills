# expect: green
# Ordinary docs that name macros and a module named test_runner in a tool that runs tests.
cat > src/test_runner.rs <<'R'
//! Runs a list of named checks. Unlike `include!`, the list is read at run time.

/// One named check.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Check {
    /// The check's name.
    pub name: String,
    /// Whether it passed.
    pub passed: bool,
}

/// The names of the checks that failed, in order.
#[must_use]
pub fn failed(checks: &[Check]) -> Vec<&str> {
    checks.iter().filter(|check| !check.passed).map(|check| check.name.as_str()).collect()
}
R
printf '\npub mod test_runner;\n' >> src/lib.rs
cat >> tests/sample_tool.rs <<'R'

#[test]
fn failed_checks_are_listed() {
    use sample_tool::test_runner::{Check, failed};
    let checks = [
        Check { name: String::from("a"), passed: true },
        Check { name: String::from("b"), passed: false },
    ];
    assert_eq!(failed(&checks), vec!["b"]);
}
R
mise exec -- cargo fmt --all
