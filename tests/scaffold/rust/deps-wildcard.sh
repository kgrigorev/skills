# expect: red Dependencies
# A wildcard version requirement.
perl -pi -e 's/^proptest = \{ version = "[^"]*"/proptest = { version = "*"/' Cargo.toml
mise exec -- cargo update --workspace --offline
