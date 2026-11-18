# expect: red No switched-off checks
# #[path] pulls in a file outside the scanned tree.
mkdir -p vendor
printf '//! Outside.\n#![allow(clippy::unwrap_used)]\n' > vendor/outside.txt
printf '\n#[path = "../vendor/outside.txt"]\nmod outside;\n' >> src/lib.rs
