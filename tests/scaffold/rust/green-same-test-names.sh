# expect: green
# The same test name in the library and in a test file: both run, so both are listed.
cat >> src/lib.rs <<'R'

#[cfg(test)]
mod tests {
    #[test]
    fn banner_starts_with_the_package_name() {
        assert!(super::banner().starts_with("sample-tool"));
    }
}
R
mise exec -- cargo fmt --all
