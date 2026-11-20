# expect: red Test
# TEST_ABORT() is what TEST_PASS() expands to: it ends the test as passed before the failing
# assertion. The lines after it never run, which the test's line coverage shows.
perl -0pi -e 's/(static void banner_names_the_program\(void\) \{\n)/$1    TEST_ABORT();\n    TEST_ASSERT_EQUAL_INT(1, 2);\n/' test/sample_tool_test.c
grep -q TEST_ABORT test/sample_tool_test.c
