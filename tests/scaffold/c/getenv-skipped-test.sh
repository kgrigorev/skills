# expect: red Test
# A failing test that returns early unless an environment variable is set. check runs the tools
# with env -i, so it is never set. The lines after the return never run.
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void broken_test(void) {\n    if (getenv("SAMPLE_TOOL_SLOW") == nullptr) {\n        return;\n    }\n    TEST_ASSERT_EQUAL_INT(1, 2);\n}\n\n$1    RUN_TEST(broken_test);\n/' test/sample_tool_test.c
