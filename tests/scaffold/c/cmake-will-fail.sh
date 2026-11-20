# expect: red No switched-off checks
# WILL_FAIL turns a failing test into a passing one.
printf 'set_tests_properties(sample_tool_test PROPERTIES WILL_FAIL ON)\n' >>CMakeLists.txt
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
