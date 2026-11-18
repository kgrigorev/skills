# expect: red Test
# A plain `return;` before a failing assertion. The lines after it never run, which the test's line
# coverage shows.
perl -0pi -e 's/(static void banner_names_the_program\(void\) \{\n)/$1    return;\n    TEST_ASSERT_EQUAL_INT(1, 2);\n/' test/sample_tool_test.c
grep -q 'return;' test/sample_tool_test.c
