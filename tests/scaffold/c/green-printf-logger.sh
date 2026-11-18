# expect: green
# A printf-style logging helper. -Wformat=2 asks for the format attribute on the wrapper, so it
# has one, in the C23 [[gnu::format]] spelling.
perl -0pi -e 's/(#include <stddef.h>)/$1\n#include <stdio.h>/' include/sample_tool.h
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Writes "sample-tool: " and the printf-style message to `stream`, then a newline.\n\/\/\/ Returns false when writing fails.\n[[nodiscard, gnu::format(printf, 2, 3)]] bool sample_tool_log(FILE *stream, const char *format,\n                                                               ...);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdarg.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

bool sample_tool_log(FILE *stream, const char *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    const int written = vfprintf(stream, format, arguments);
    va_end(arguments);
    if (written < 0) {
        return false;
    }
    return fputc('\n', stream) != EOF;
}
X
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void log_writes_one_line(void) {\n    FILE *stream = tmpfile();\n    TEST_ASSERT_NOT_NULL(stream);\n    TEST_ASSERT_TRUE(sample_tool_log(stream, "%d files", 3));\n    TEST_ASSERT_EQUAL_INT(0, fseek(stream, 0, SEEK_SET));\n    char line[32];\n    TEST_ASSERT_NOT_NULL(fgets(line, sizeof line, stream));\n    TEST_ASSERT_EQUAL_STRING("3 files\\n", line);\n    TEST_ASSERT_EQUAL_INT(0, fclose(stream));\n}\n\n$1    RUN_TEST(log_writes_one_line);\n/' test/sample_tool_test.c
scripts/format
