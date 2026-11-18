# expect: red Settings files
# A test profile and a per-package profile.
printf '\n[profile.test]\nopt-level = 3\n[profile.dev.package."*"]\ndebug-assertions = false\n' >> Cargo.toml
