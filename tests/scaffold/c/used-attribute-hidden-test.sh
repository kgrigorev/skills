# expect: red syntax tree
# A failing test that main never runs, marked `used` so -Wunused-function stays quiet. (Line
# coverage would catch it too.)
perl -0pi -e 's/(int main\(void\) \{\n)/[[gnu::used]] static void broken_test(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n\n$1/' test/sample_tool_test.c
grep -q broken_test test/sample_tool_test.c
