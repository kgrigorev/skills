# expect: red Format
# Code that rustfmt would change.
perl -pi -e 's/text.split_whitespace\(\).count\(\)/text  .split_whitespace( ) .count()/' src/lib.rs
