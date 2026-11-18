# expect: green
# An I/O shell around a tested core: main reads lines from stdin and sums them; the library
# parses one line into a status enum plus an out-parameter, and says what a status means.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ The result of sample_tool_parse_count.\ntypedef enum sample_tool_status {\n    SAMPLE_TOOL_OK,\n    SAMPLE_TOOL_EMPTY,\n    SAMPLE_TOOL_NOT_A_NUMBER,\n    SAMPLE_TOOL_OUT_OF_RANGE,\n} sample_tool_status;\n\n\/\/\/ Parses a non-negative decimal count, such as "42" or "42\\n", into `out`.\n\/\/\/ On failure `out` stays unchanged.\n[[nodiscard]] sample_tool_status sample_tool_parse_count(const char *text, long *out);\n\n\/\/\/ A short description of `status` for error messages. The text is static.\n[[nodiscard]] const char *sample_tool_status_text(sample_tool_status status);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <errno.h>\n#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

sample_tool_status sample_tool_parse_count(const char *text, long *out) {
    if (text[0] == '\0' || text[0] == '\n') {
        return SAMPLE_TOOL_EMPTY;
    }
    char *end = nullptr;
    errno = 0;
    const long value = strtol(text, &end, 10);
    if (end == text || (*end != '\0' && *end != '\n') || value < 0) {
        return SAMPLE_TOOL_NOT_A_NUMBER;
    }
    if (errno == ERANGE) {
        return SAMPLE_TOOL_OUT_OF_RANGE;
    }
    *out = value;
    return SAMPLE_TOOL_OK;
}

const char *sample_tool_status_text(sample_tool_status status) {
    switch (status) {
    case SAMPLE_TOOL_OK:
        return "ok";
    case SAMPLE_TOOL_EMPTY:
        return "empty line";
    case SAMPLE_TOOL_NOT_A_NUMBER:
        return "not a number";
    case SAMPLE_TOOL_OUT_OF_RANGE:
        return "number out of range";
    }
    return "unknown status";
}
X
cat >app/main.c <<'X'
/// The sample-tool program: prints the sum of the counts on stdin, one per line.
#include "sample_tool.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    char line[64];
    long total = 0;
    while (fgets(line, sizeof line, stdin) != nullptr) {
        long count = 0;
        const sample_tool_status status = sample_tool_parse_count(line, &count);
        if (status != SAMPLE_TOOL_OK) {
            (void)fprintf(stderr, "sample-tool: %s\n", sample_tool_status_text(status));
            return EXIT_FAILURE;
        }
        if (count > LONG_MAX - total) {
            (void)fputs("sample-tool: the total is too large\n", stderr);
            return EXIT_FAILURE;
        }
        total += count;
    }
    if (ferror(stdin) != 0) {
        (void)fputs("sample-tool: cannot read stdin\n", stderr);
        return EXIT_FAILURE;
    }
    return printf("%ld\n", total) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
}
X
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void parse_count_reads_a_line(void) {\n    long count = 0;\n    TEST_ASSERT_EQUAL_INT(SAMPLE_TOOL_OK, sample_tool_parse_count("42\\n", &count));\n    TEST_ASSERT_TRUE(count == 42);\n}\n\nstatic void parse_count_rejects_bad_lines(void) {\n    long count = 7;\n    TEST_ASSERT_EQUAL_INT(SAMPLE_TOOL_EMPTY, sample_tool_parse_count("\\n", &count));\n    TEST_ASSERT_EQUAL_INT(SAMPLE_TOOL_NOT_A_NUMBER, sample_tool_parse_count("4x", &count));\n    TEST_ASSERT_EQUAL_INT(SAMPLE_TOOL_NOT_A_NUMBER, sample_tool_parse_count("-1", &count));\n    TEST_ASSERT_EQUAL_INT(SAMPLE_TOOL_OUT_OF_RANGE,\n                          sample_tool_parse_count("99999999999999999999", &count));\n    TEST_ASSERT_TRUE(count == 7);\n    TEST_ASSERT_EQUAL_STRING("not a number", sample_tool_status_text(SAMPLE_TOOL_NOT_A_NUMBER));\n}\n\n$1    RUN_TEST(parse_count_reads_a_line);\n    RUN_TEST(parse_count_rejects_bad_lines);\n/' test/sample_tool_test.c
