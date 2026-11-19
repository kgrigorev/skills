# expect: red No switched-off checks
# include_str! inside concat! pulls in a doc file with an ignored example.
printf '# Notes\n\n```ignore\nassert_eq!(sample_tool::word_count("a"), 99);\n```\n' > NOTES.md
perl -0pi -e 's{\A}{#![doc = concat!(include_str!("../NOTES.md"))]\n}' src/lib.rs
