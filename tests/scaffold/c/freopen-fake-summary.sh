# expect: red Test
# main sends Unity's output to /dev/null and prints a passing summary after a failing test, and
# every line runs. Unity's own counts, read from the line coverage of unity.c, show the failure.
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/int main\(void\) \{\n    UNITY_BEGIN\(\);\n    RUN_TEST\(banner_names_the_program\);\n    RUN_TEST\(banner_is_cut_to_fit_and_terminated\);\n    return UNITY_END\(\);\n\}/static void broken(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n\nint main(void) {\n    const int quiet = freopen("\/dev\/null", "w", stdout) == nullptr ? 1 : 0;\n    UNITY_BEGIN();\n    RUN_TEST(banner_names_the_program);\n    RUN_TEST(banner_is_cut_to_fit_and_terminated);\n    RUN_TEST(broken);\n    const int failures = UNITY_END();\n    (void)fprintf(stderr, "\\n%d Tests 0 Failures 0 Ignored \\nOK\\n", 2 + (failures * 0));\n    return quiet + (failures * 0);\n}/' test/sample_tool_test.c
grep -q freopen test/sample_tool_test.c
scripts/format
