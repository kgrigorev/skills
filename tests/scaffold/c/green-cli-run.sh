# expect: green
# The CLI run pattern: main only calls sample_tool_run with the real streams, and a Unity test
# runs it with tmpfile() streams and reads back what it printed.
perl -0pi -e 's/(#include <stddef.h>)/$1\n#include <stdio.h>/' include/sample_tool.h
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Runs the program: prints the banner to `out`, or a usage line to `err` when it gets any\n\/\/\/ argument. Returns the exit status. The streams stay open and belong to the caller.\n[[nodiscard]] int sample_tool_run(int argc, char *argv[], FILE *out, FILE *err);\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

int sample_tool_run(int argc, char *argv[], FILE *out, FILE *err) {
    if (argc > 1) {
        (void)fprintf(err, "usage: %s\n", argv[0]);
        return EXIT_FAILURE;
    }
    char text[128];
    if (sample_tool_banner(text, sizeof text) >= sizeof text) {
        return EXIT_FAILURE;
    }
    return fprintf(out, "%s\n", text) < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
}
X
cat >app/main.c <<'X'
/// The sample-tool program. Keep it thin: the work happens in the library.
#include "sample_tool.h"

#include <stdio.h>

int main(int argc, char *argv[]) { return sample_tool_run(argc, argv, stdout, stderr); }
X
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/\/\/ Runs the program with `argc` arguments and returns its exit status. Its stdout goes to `out`.\nstatic int run(int argc, char *argv[], char *out, size_t capacity) {\n    FILE *out_file = tmpfile();\n    FILE *err_file = tmpfile();\n    TEST_ASSERT_NOT_NULL(out_file);\n    TEST_ASSERT_NOT_NULL(err_file);\n    const int status = sample_tool_run(argc, argv, out_file, err_file);\n    TEST_ASSERT_EQUAL_INT(0, fseek(out_file, 0, SEEK_SET));\n    const size_t read = fread(out, 1, capacity - 1, out_file);\n    out[read] = \x27\\0\x27;\n    TEST_ASSERT_EQUAL_INT(0, fclose(out_file));\n    TEST_ASSERT_EQUAL_INT(0, fclose(err_file));\n    return status;\n}\n\nstatic void run_prints_the_banner(void) {\n    char name[] = "sample-tool";\n    char *argv[] = {name, nullptr};\n    char out[256];\n    TEST_ASSERT_EQUAL_INT(EXIT_SUCCESS, run(1, argv, out, sizeof out));\n    TEST_ASSERT_EQUAL_STRING("sample-tool: A sample tool that tests the template\\n", out);\n}\n\nstatic void run_rejects_arguments(void) {\n    char name[] = "sample-tool";\n    char extra[] = "--color";\n    char *argv[] = {name, extra, nullptr};\n    char out[256];\n    TEST_ASSERT_EQUAL_INT(EXIT_FAILURE, run(2, argv, out, sizeof out));\n    TEST_ASSERT_EQUAL_STRING("", out);\n}\n\n$1    RUN_TEST(run_prints_the_banner);\n    RUN_TEST(run_rejects_arguments);\n/' test/sample_tool_test.c
scripts/format
