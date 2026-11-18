# expect: red Settings files
# A quoted key in a [profile] table.
printf '\n[profile.dev]\n"overflow-checks" = false\n' >> Cargo.toml
