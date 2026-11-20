# expect: red No switched-off checks
# An inner doc comment (//!) example marked ignore: doc comments are still scanned.
{
  printf '//! ```ignore\n//! assert_eq!(sample_tool::word_count("a"), 99);\n//! ```\n'
  cat src/lib.rs
} > l.tmp
mv l.tmp src/lib.rs
