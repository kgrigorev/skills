# expect: red Test
# Control: a failing Unity assertion fails the check.
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
