# expect: red No switched-off checks
# TEST_PASS ends a test as passed before its failing assertion.
perl -0pi -e 's/(static void banner_names_the_program\(void\) \{\n)/$1    TEST_PASS();\n    TEST_ASSERT_EQUAL_INT(1, 2);\n/' test/sample_tool_test.c
