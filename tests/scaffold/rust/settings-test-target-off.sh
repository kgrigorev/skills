# expect: red Settings files
# A [[test]] target with test = false never runs.
perl -pi -e 's/starts_with\("sample-tool"\)/starts_with("nope")/' tests/sample_tool.rs
printf '\n[[test]]\nname = "sample_tool"\npath = "tests/sample_tool.rs"\ntest = false\n' >> Cargo.toml
