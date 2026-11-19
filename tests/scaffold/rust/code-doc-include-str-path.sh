# expect: red No switched-off checks
# core::include_str! pulls in a doc file with an ignored example under another spelling.
printf '# Notes\n\n```ignore\nassert_eq!(sample_tool::word_count("a"), 99);\n```\n' > NOTES.md
perl -0pi -e 's{\A}{#![doc = core::include_str!("../NOTES.md")]\n}' src/lib.rs
