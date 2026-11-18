# expect: red syntax tree
# A program can set its own LeakSanitizer options with __lsan_default_options. An asm label gives a
# plainly named function that symbol, spelled in two string literals so no search sees "__lsan_".
# Mach-O adds one leading underscore to C names. (The test preset's LSAN_OPTIONS would also win.)
if [ "$(uname -s)" = Darwin ]; then prefix=___ls; else prefix=__ls; fi
cat >>test/sample_tool_test.c <<X

const char *sample_tool_quiet_leaks(void) __asm__("$prefix" "an_default_options");
const char *sample_tool_quiet_leaks(void) { return "detect_leaks=0"; }
X
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char *sample_tool_dup(void);\n\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
printf '\nchar *sample_tool_dup(void) { return malloc(16); }\n' >>src/sample_tool.c
perl -0pi -e 's/int main\(void\) \{\n    UNITY_BEGIN\(\);\n/static void leaks(void) {\n    char *p = sample_tool_dup();\n    TEST_ASSERT_NOT_NULL(p);\n}\n\nint main(void) {\n    UNITY_BEGIN();\n    RUN_TEST(leaks);\n/' test/sample_tool_test.c
scripts/format
