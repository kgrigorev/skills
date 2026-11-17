# expect: red Dependencies
# .rs files no target reaches: cargo never compiles them.
printf 'pub fn parse(s: &str) -> i64 { s.parse().unwrap() + this_does_not_compile }\n' > src/parser.rs
mkdir -p tests/unit
printf '#[test] fn fails() { assert!(false); }\n' > tests/unit/parse.rs
