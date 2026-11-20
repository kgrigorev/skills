# expect: red Test
# A wrong property.
perl -pi -e 's/word_count\(&left\) \+ word_count\(&right\)/word_count(&left) + word_count(&right) + 1/' tests/sample_tool.rs
