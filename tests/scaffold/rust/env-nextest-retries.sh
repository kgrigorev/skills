# expect: red Test
# env: NEXTEST_RETRIES=5
# Retries from the environment. The test fails every time anyway, but the variable must not apply.
perl -pi -e 's/starts_with\("sample-tool"\)/starts_with("nope")/' tests/sample_tool.rs
