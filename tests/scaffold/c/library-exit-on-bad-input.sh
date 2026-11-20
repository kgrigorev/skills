# expect: red syntax tree
# The library ends the program on bad input instead of returning an error to its caller
# (CODING_STANDARDS.md). abort() is allowed for broken invariants, so only exit() is rejected.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Parses one decimal digit.\n[[nodiscard]] int sample_tool_digit(char c);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

int sample_tool_digit(char c) {
    if (c < '0' || c > '9') {
        (void)fputs("not a digit\n", stderr);
        exit(EXIT_FAILURE);
    }
    return c - '0';
}
X
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void digit_parses(void) { TEST_ASSERT_EQUAL_INT(4, sample_tool_digit(\x274\x27)); }\n\n$1    RUN_TEST(digit_parses);\n/' test/sample_tool_test.c
