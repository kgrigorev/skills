# expect: green
# An error value that carries where it happened, and a function that formats it with snprintf
# into a caller's buffer, checking snprintf's result.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ What went wrong while reading input, and on which line (1 is the first).\ntypedef struct sample_tool_error {\n    const char *what;\n    size_t line;\n} sample_tool_error;\n\n\/\/\/ Writes "line N: what" into `out`, which holds `capacity` bytes. Returns false when the text\n\/\/\/ does not fit or cannot be formatted; `out` then holds a cut or empty text.\n[[nodiscard]] bool sample_tool_format_error(char *out, size_t capacity, sample_tool_error error);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

bool sample_tool_format_error(char *out, size_t capacity, sample_tool_error error) {
    const int written = snprintf(out, capacity, "line %zu: %s", error.line, error.what);
    if (written < 0) {
        return false;
    }
    return (size_t)written < capacity;
}
X
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void error_names_the_line(void) {\n    char text[32];\n    const sample_tool_error error = {.what = "not a number", .line = 3};\n    TEST_ASSERT_TRUE(sample_tool_format_error(text, sizeof text, error));\n    TEST_ASSERT_EQUAL_STRING("line 3: not a number", text);\n}\n\nstatic void error_reports_a_cut_text(void) {\n    char text[8];\n    const sample_tool_error error = {.what = "not a number", .line = 3};\n    TEST_ASSERT_FALSE(sample_tool_format_error(text, sizeof text, error));\n    TEST_ASSERT_EQUAL_STRING("line 3:", text);\n}\n\n$1    RUN_TEST(error_names_the_line);\n    RUN_TEST(error_reports_a_cut_text);\n/' test/sample_tool_test.c
