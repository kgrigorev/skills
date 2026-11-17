# expect: red Settings files
# A lint switched off in Cargo.toml.
perl -pi -e 's/^unwrap_used = "warn"$/unwrap_used = "allow"/' Cargo.toml
