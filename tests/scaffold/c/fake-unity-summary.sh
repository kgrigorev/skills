# expect: red Test
# main prints the text of a Unity summary and returns 0, so the failing tests never run. The rest
# of main never runs, which the test's line coverage shows.
perl -0pi -e 's/int main\(void\) \{\n    UNITY_BEGIN\(\);\n    RUN_TEST\(banner_names_the_program\);\n    RUN_TEST\(banner_is_cut_to_fit_and_terminated\);\n    return UNITY_END\(\);\n\}/static void broken_test(void) { TEST_ASSERT_EQUAL_INT(1, 2); }\n\nint main(void) {\n    if (puts("\\n2 Tests 0 Failures 0 Ignored \\nOK") >= 0) {\n        return 0;\n    }\n    UNITY_BEGIN();\n    RUN_TEST(banner_names_the_program);\n    RUN_TEST(banner_is_cut_to_fit_and_terminated);\n    RUN_TEST(broken_test);\n    return UNITY_END();\n}/' test/sample_tool_test.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
grep -q 'puts(' test/sample_tool_test.c
