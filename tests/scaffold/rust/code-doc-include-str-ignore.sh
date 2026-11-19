# expect: red No switched-off checks
# A doc example marked ignore in a file that #[doc = include_str!(...)] pulls in.
printf '# Notes\n\n```ignore\nassert_eq!(sample_tool::word_count("a"), 99);\n```\n' > NOTES.md
perl -0pi -e 's{\A}{#![doc = include_str!("../NOTES.md")]\n}' src/lib.rs
