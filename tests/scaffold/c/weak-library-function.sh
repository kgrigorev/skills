# expect: red syntax tree
# A weak library function, which a test's stub would replace without a duplicate symbol.
perl -pi -e 's/^size_t sample_tool_banner\(/[[gnu::weak]] size_t sample_tool_banner(/' src/sample_tool.c
grep -q 'gnu::weak' src/sample_tool.c
scripts/format
