# expect: red Dependencies
# A dependency nothing uses.
perl -pi -e 's/^\[dependencies\]$/[dependencies]\nbitflags = "2"/' Cargo.toml
mise exec -- cargo update --workspace --offline
