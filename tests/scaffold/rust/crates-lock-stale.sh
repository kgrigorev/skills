# expect: red Crates
# A new dependency without an updated Cargo.lock.
perl -pi -e 's/^\[dependencies\]$/[dependencies]\nbitflags = "2"/' Cargo.toml
