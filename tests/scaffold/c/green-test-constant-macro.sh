# expect: green
# A test file with a named constant for its buffer size, spelled TEST_BUFFER_SIZE.
perl -0pi -e 's/(\/\/ Unity calls these)/\/\/ Large enough for every banner the tests build.\n#define TEST_BUFFER_SIZE 128\n\n$1/' test/sample_tool_test.c
perl -0pi -e 's/static void banner_names_the_program\(void\) \{\n    char banner\[128\];/static void banner_names_the_program(void) {\n    char banner[TEST_BUFFER_SIZE];/' test/sample_tool_test.c
grep -q 'banner\[TEST_BUFFER_SIZE\]' test/sample_tool_test.c
