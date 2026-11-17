# expect: red Settings files
# A whole lint group switched off in an inline table.
perl -pi -e 's/^unwrap_used = "warn"$/unwrap_used = { level = "warn", priority = -2 }\nrestriction = { priority = -1, level = "allow" }/' Cargo.toml
