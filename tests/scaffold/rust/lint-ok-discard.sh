# expect: red Lint
# `.ok();` throws away a Result.
printf '\n/// Writes a file and ignores failure.\npub fn save(path: &str) {\n    std::fs::write(path, "x").ok();\n}\n' >> src/lib.rs
