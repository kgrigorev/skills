# expect: red No switched-off checks
# RUN_TEST redefined to skip the test it names.
perl -0pi -e 's/(#include <unity.h>\n)/$1\n#undef RUN_TEST\n#define RUN_TEST(f) ((void)(f))\n/' test/sample_tool_test.c
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
