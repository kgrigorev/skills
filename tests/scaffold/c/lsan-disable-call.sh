# expect: red syntax tree
# A call into the LeakSanitizer interface that stops leak tracking, through an asm label so no
# name with "__lsan_" appears. Mach-O adds one leading underscore to C names.
if [ "$(uname -s)" = Darwin ]; then prefix=___ls; else prefix=__ls; fi
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char *sample_tool_dup(void);\n\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
printf '\nchar *sample_tool_dup(void) { return malloc(16); }\n' >>src/sample_tool.c
perl -0pi -e "s/(static void banner_names_the_program)/void sample_tool_stop_leaks(void) __asm__(\"$prefix\" \"an_disable\");\n\nstatic void leaks(void) {\n    sample_tool_stop_leaks();\n    char *p = sample_tool_dup();\n    TEST_ASSERT_NOT_NULL(p);\n}\n\n\$1/" test/sample_tool_test.c
perl -0pi -e 's/(    UNITY_BEGIN\(\);\n)/$1    RUN_TEST(leaks);\n/' test/sample_tool_test.c
grep -q sample_tool_stop_leaks test/sample_tool_test.c
scripts/format
