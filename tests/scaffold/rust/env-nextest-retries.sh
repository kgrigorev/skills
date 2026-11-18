# expect: red Test
# env: NEXTEST_RETRIES=5
# A flaky test that fails on the first try and passes on a retry. Only the unset makes it red.
cat >> tests/sample_tool.rs <<'R'

#[test]
fn flaky() {
    let marker = std::path::Path::new(env!("CARGO_TARGET_TMPDIR")).join("flaky-marker");
    if std::fs::metadata(&marker).is_err() {
        std::fs::write(&marker, "x").unwrap();
        panic!("first try fails");
    }
}
R
rm -f target/tmp/flaky-marker
