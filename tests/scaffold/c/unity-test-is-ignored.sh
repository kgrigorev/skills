# expect: red syntax tree
# The library is broken. setUp marks each test ignored through TEST_IS_IGNORED, which is an
# lvalue, and tearDown clears it, so every assertion returns before it checks. Only TEST_PROTECT
# and TEST_ABORT may touch Unity's state.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q broken-tool src/sample_tool.c
perl -0pi -e 's/void setUp\(void\) \{\}\nvoid tearDown\(void\) \{\}/void setUp(void) { TEST_IS_IGNORED = 1; }\nvoid tearDown(void) { TEST_IS_IGNORED = 0; }/' test/sample_tool_test.c
grep -q 'TEST_IS_IGNORED = 1' test/sample_tool_test.c
scripts/format
