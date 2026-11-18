# expect: red Test
# A failing test that main never runs, kept from -Wunused-function by `(void)name;`. Its lines
# never run, which the test's line coverage shows.
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void broken_test(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n\n$1    (void)broken_test;\n/' test/sample_tool_test.c
grep -q '(void)broken_test' test/sample_tool_test.c
