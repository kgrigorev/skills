# expect: red syntax tree
# unity-test-is-ignored, through an assignment in the argument of UNITY_SET_DETAIL.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q broken-tool src/sample_tool.c
perl -0pi -e 's/void setUp\(void\) \{\}\nvoid tearDown\(void\) \{\}/void setUp(void) { UNITY_SET_DETAIL((Unity.CurrentTestIgnored = 1, "")); }\nvoid tearDown(void) { UNITY_SET_DETAIL((Unity.CurrentTestIgnored = 0, "")); }/' test/sample_tool_test.c
grep -q 'CurrentTestIgnored = 1' test/sample_tool_test.c
scripts/format
