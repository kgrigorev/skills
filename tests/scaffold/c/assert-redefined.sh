# expect: red No switched-off checks
# A test file that redefines a Unity assertion to do nothing, then fails it.
perl -0pi -e 's/(#include <unity.h>\n)/$1\n#undef TEST_ASSERT_EQUAL_INT\n#define TEST_ASSERT_EQUAL_INT(e, a) ((void)(e), (void)(a))\n/' test/sample_tool_test.c
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
