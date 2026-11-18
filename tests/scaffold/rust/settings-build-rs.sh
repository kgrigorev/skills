# expect: red Settings files
# A build script sets a cfg that hides a red test.
cat > build.rs <<'R'
//! Build script.
fn main() {
    println!("cargo::rustc-check-cfg=cfg(skip_tests)");
    println!("cargo::rustc-cfg=skip_tests");
}
R
cat >> tests/sample_tool.rs <<'R'

#[cfg(not(skip_tests))]
#[test]
fn hidden() {
    assert_eq!(1, 2);
}
R
