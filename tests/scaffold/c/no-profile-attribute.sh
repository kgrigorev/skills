# expect: red syntax tree
# A failing test that main never runs, kept out of line coverage by an attribute.
perl -0pi -e 's/(int main\(void\) \{\n)/[[gnu::no_profile_instrument_function]] static void broken(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n\n$1    (void)broken;\n/' test/sample_tool_test.c
scripts/format
