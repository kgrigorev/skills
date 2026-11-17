# expect: red Settings files
# A build script named in [package].
perl -pi -e 's/^publish = false$/publish = false\nbuild = "tools\/gen.rs"/' Cargo.toml
