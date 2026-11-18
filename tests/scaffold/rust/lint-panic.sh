# expect: red Lint
# panic! in library code.
printf '\n/// Fails.\n///\n/// # Panics\n///\n/// Always.\npub fn fail() {\n    panic!("no");\n}\n' >> src/lib.rs
