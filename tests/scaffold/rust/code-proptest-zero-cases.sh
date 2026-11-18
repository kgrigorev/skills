# expect: red No switched-off checks
# Zero proptest cases, with a wrong property.
perl -0pi -e 's/proptest! \{\n/proptest! {\n    #![proptest_config(ProptestConfig::with_cases(0))]\n/' tests/sample_tool.rs
perl -pi -e 's/word_count\(&left\) \+ word_count\(&right\)/999/' tests/sample_tool.rs
