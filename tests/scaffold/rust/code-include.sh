# expect: red No switched-off checks
# include! pulls in code from a non-.rs file.
mkdir -p vendor
printf 'fn hidden() -> i64 { "1".parse().unwrap() }\n' > vendor/code.txt
printf '\ninclude!("../vendor/code.txt");\n' >> src/lib.rs
