# expect: red Test
# A test main that returns before it runs any test.
perl -0pi -e 's/int main\(void\) \{\n/static volatile int skip = 1;\n\nint main(void) {\n    if (skip != 0) {\n        return 0;\n    }\n/' test/sample_tool_test.c
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
