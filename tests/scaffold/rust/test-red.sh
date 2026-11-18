# expect: red Test
# A plain failing test.
perl -pi -e 's/starts_with\("sample-tool"\)/starts_with("nope")/' tests/sample_tool.rs
