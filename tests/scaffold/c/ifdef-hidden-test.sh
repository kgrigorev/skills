# expect: red No switched-off checks
# A failing test kept in the file but compiled only when a macro nobody defines is set. Coverage
# cannot see code that is not compiled, so a test file has no conditional directives.
perl -0pi -e 's/(int main\(void\) \{\n)/#ifdef SAMPLE_TOOL_SLOW_TESTS\nstatic void broken_test(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n#endif\n\n$1/' test/sample_tool_test.c
perl -0pi -e 's/(    return UNITY_END\(\);)/#ifdef SAMPLE_TOOL_SLOW_TESTS\n    RUN_TEST(broken_test);\n#endif\n$1/' test/sample_tool_test.c
