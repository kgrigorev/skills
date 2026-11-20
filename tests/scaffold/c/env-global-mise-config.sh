# expect: red Test
# env: MISE_GLOBAL_CONFIG_FILE=../global-mise.toml
# A global mise config cannot reach the tests: a leak still fails.
printf '[env]\nLSAN_OPTIONS = "detect_leaks=0"\n' >../global-mise.toml
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char *sample_tool_dup(void);\n\n$1/' include/sample_tool.h
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
printf '\nchar *sample_tool_dup(void) { return malloc(16); }\n' >>src/sample_tool.c
perl -0pi -e 's/int main\(void\) \{\n    UNITY_BEGIN\(\);\n/static void leaks(void) {\n    char *p = sample_tool_dup();\n    TEST_ASSERT_NOT_NULL(p);\n}\n\nint main(void) {\n    UNITY_BEGIN();\n    RUN_TEST(leaks);\n/' test/sample_tool_test.c
