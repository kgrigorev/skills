# expect: red Test
# Control: AddressSanitizer catches a heap read past the end in a test.
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char sample_tool_peek(const char *s, size_t i);\n\n$1/' include/sample_tool.h
printf '\nchar sample_tool_peek(const char *s, size_t i) { return s[i]; }\n' >>src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/int main\(void\) \{\n    UNITY_BEGIN\(\);\n/static void peek_past_end(void) {\n    char *p = malloc(4);\n    TEST_ASSERT_NOT_NULL(p);\n    memset(p, 1, 4);\n    volatile size_t i = 4;\n    TEST_ASSERT_EQUAL_CHAR(sample_tool_peek(p, i), sample_tool_peek(p, i));\n    free(p);\n}\n\nint main(void) {\n    UNITY_BEGIN();\n    RUN_TEST(peek_past_end);\n/' test/sample_tool_test.c
