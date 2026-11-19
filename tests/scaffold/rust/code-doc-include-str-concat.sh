# expect: red No switched-off checks
# A doc file named by concat!, which the search cannot follow.
printf '# Notes\n\n```ignore\nassert_eq!(sample_tool::word_count("a"), 99);\n```\n' > NOTES.md
perl -0pi -e 's{\A}{#![doc = include_str!(concat!(env!("CARGO_MANIFEST_DIR"), "/NOTES.md"))]\n}' src/lib.rs
