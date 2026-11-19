# expect: red No switched-off checks
# A doc file outside the folder of the .rs file, by absolute path, which the search skips.
printf '# Notes\n\n```ignore\nassert_eq!(sample_tool::word_count("a"), 99);\n```\n' > NOTES.md
perl -0pi -e "s{\\A}{#![doc = include_str!(\"$PWD/NOTES.md\")]\n}" src/lib.rs
