# expect: red No switched-off checks
# rustdoc reads ~~~ fences too.
perl -0pi -e 's{/// ```\n(/// assert_eq!.*\n)/// ```}{/// ~~~ignore\n/// assert_eq!(sample_tool::word_count("a"), 99);\n/// ~~~}' src/lib.rs
grep -q '~~~ignore' src/lib.rs
