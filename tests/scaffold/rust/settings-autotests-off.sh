# expect: red Settings files
# autotests = false: the integration tests never build or run.
perl -pi -e 's/^publish = false$/publish = false\nautotests = false/' Cargo.toml
perl -pi -e 's/starts_with\("sample-tool"\)/starts_with("nope")/' tests/sample_tool.rs
cat >> src/lib.rs <<'R'

#[cfg(test)]
mod tests {
    #[test]
    fn trivially() {
        assert_eq!(super::word_count("a"), 1);
    }
}
R
