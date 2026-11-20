# expect: red Settings files
# A \u escape spells "allow" without its letters.
perl -pi -e 's/^unwrap_used = "warn"$/unwrap_used = "al\\u006cow"/' Cargo.toml
