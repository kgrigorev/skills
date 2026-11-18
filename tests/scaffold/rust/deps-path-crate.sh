# expect: red Dependencies
# A path dependency in the repo is a crate outside every lint: unsafe and unwrap pass there.
mkdir -p helper/src
printf '[package]\nname = "helper"\nversion = "0.1.0"\nedition = "2024"\npublish = false\n' > helper/Cargo.toml
printf 'pub fn parse(s: &str) -> i64 { let p = s.as_ptr(); unsafe { let _ = *p; } s.parse().unwrap() }\n' > helper/src/lib.rs
perl -pi -e 's/^\[dependencies\]$/[dependencies]\nhelper = { path = "helper" }/' Cargo.toml
printf '\n/// Parses a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    helper::parse(s)\n}\n' >> src/lib.rs
mise exec -- cargo generate-lockfile --offline
mise exec -- cargo fmt --all
