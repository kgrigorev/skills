# expect: red Settings files
# Nested rustfmt files switch formatting off for their folders.
printf 'disable_all_formatting = true\n' > src/rustfmt.toml
printf 'disable_all_formatting = true\n' > tests/.rustfmt.toml
perl -pi -e 's/text.split_whitespace\(\).count\(\)/text  .split_whitespace( ) .count()/' src/lib.rs
