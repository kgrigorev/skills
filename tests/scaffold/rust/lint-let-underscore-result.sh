# expect: red Lint
# `let _ =` throws away a Result.
printf '\n/// Writes a file and ignores failure.\npub fn save(path: &str) {\n    let _ = std::fs::write(path, "x");\n}\n' >> src/lib.rs
