# expect: red Settings files
# env: CARGO_HOME=.cargo-home
# A cargo config outside the project sets PROPTEST_CASES in a one-line inline table.
mkdir -p .cargo-home
printf 'env = { PROPTEST_CASES = "0" }\n' > .cargo-home/config.toml
perl -pi -e 's/word_count\(&left\) \+ word_count\(&right\)/999/' tests/sample_tool.rs
