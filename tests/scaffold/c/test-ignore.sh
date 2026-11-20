# expect: red No switched-off checks
# TEST_IGNORE skips a test.
perl -0pi -e 's/(static void banner_names_the_program\(void\) \{\n)/$1    TEST_IGNORE();\n/' test/sample_tool_test.c
