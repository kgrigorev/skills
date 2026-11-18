# expect: red Lint
# Library code that ends the program.
printf '\n/// Stops.\npub fn stop() {\n    std::process::exit(1);\n}\n' >> src/lib.rs
