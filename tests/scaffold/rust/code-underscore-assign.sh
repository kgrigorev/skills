# expect: red No switched-off checks
# `_ = f();` throws away a Result.
printf '\n/// Writes a file and ignores failure.\npub fn save(path: &str) {\n    _ = std::fs::write(path, "x");\n}\n' >> src/lib.rs
