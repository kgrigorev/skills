# expect: red Lint
# std::process::abort, a disallowed method.
printf '\n/// Stops.\npub fn stop() {\n    std::process::abort();\n}\n' >> src/lib.rs
