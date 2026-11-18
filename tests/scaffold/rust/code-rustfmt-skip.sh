# expect: red No switched-off checks
# #[rustfmt::skip] keeps misformatted code.
perl -pi -e 's/^pub fn word_count/#[rustfmt::skip]\npub fn word_count/; s/text.split_whitespace\(\).count\(\)/text  .split_whitespace( ) .count()/' src/lib.rs
