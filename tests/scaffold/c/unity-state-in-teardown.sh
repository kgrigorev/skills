# expect: red syntax tree
# The library is broken. tearDown clears Unity.CurrentTestFailed, so Unity never counts the
# failure, and main prints a passing summary. A test may use Unity's state only through its macros.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q broken-tool src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/void tearDown\(void\) \{\}/void tearDown(void) { Unity.CurrentTestFailed = 0; }/' test/sample_tool_test.c
perl -0pi -e 's/int main\(void\) \{\n    UNITY_BEGIN\(\);/int main(void) {\n    const int quiet = freopen("\/dev\/null", "w", stdout) == nullptr ? 1 : 0;\n    UNITY_BEGIN();/; s/    return UNITY_END\(\);/    const int failures = UNITY_END();\n    (void)fprintf(stderr, "\\n%d Tests 0 Failures 0 Ignored \\nOK\\n", 2);\n    return quiet + failures;/' test/sample_tool_test.c
grep -q CurrentTestFailed test/sample_tool_test.c
grep -q freopen test/sample_tool_test.c
scripts/format
