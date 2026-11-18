# expect: red Lint
# Debug output left in.
perl -pi -e 's/text.split_whitespace\(\).count\(\)/dbg!(text.split_whitespace().count())/' src/lib.rs
