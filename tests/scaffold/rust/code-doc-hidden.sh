# expect: red No switched-off checks
# #[doc(hidden)] takes a public item out of missing_docs.
printf '\n#[doc(hidden)]\n#[must_use]\npub fn undocumented() -> u8 {\n    1\n}\n' >> src/lib.rs
