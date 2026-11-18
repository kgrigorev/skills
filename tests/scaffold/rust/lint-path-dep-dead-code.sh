# expect: red Lint
# Warnings in a path dependency fail too (build.warnings covers local packages).
mkdir -p helper/src
printf '[package]\nname = "helper"\nversion = "0.1.0"\nedition = "2024"\npublish = false\n' > helper/Cargo.toml
printf '//! Helper.\n\n/// Parses.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    s.parse().unwrap_or(0)\n}\n\nfn unused() {}\n' > helper/src/lib.rs
perl -pi -e 's/^\[dependencies\]$/[dependencies]\nhelper = { path = "helper" }/' Cargo.toml
printf '\n/// Parses a number.\n#[must_use]\npub fn parse(s: &str) -> i64 {\n    helper::parse(s)\n}\n' >> src/lib.rs
mise exec -- cargo generate-lockfile --offline
