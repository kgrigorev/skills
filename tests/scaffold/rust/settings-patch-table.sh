# expect: red Settings files
# [patch] swaps a crates.io crate for other code.
printf '\n[patch.crates-io]\nproptest = { path = "vendor/proptest" }\n' >> Cargo.toml
