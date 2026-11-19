# expect: red syntax tree
# unity-ignore-in-setup, with setUp and tearDown in an OBJECT library under test/ that the test
# links. The Unity rule applies to every file.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q broken-tool src/sample_tool.c
cat > test/fixture.c <<'X'
/// Shared setUp and tearDown for the tests.
#include <unity.h>

void setUp(void) { Unity.CurrentTestIgnored = 1; }
void tearDown(void) { Unity.CurrentTestIgnored = 0; }
X
perl -0pi -e 's|// Unity calls these around every test.\nvoid setUp\(void\) \{\}\nvoid tearDown\(void\) \{\}\n\n||' test/sample_tool_test.c
! grep -q setUp test/sample_tool_test.c
perl -0pi -e 's/(if\(BUILD_TESTING\)\n  add_unity_test)/if(BUILD_TESTING)\n  add_library(fixture OBJECT test\/fixture.c)\n  target_link_libraries(fixture PRIVATE unity)\nendif()\n\n$1/' CMakeLists.txt
perl -pi -e 's{add_unity_test\(sample_tool_test test/sample_tool_test.c sample_tool\)}{add_unity_test(sample_tool_test test/sample_tool_test.c sample_tool fixture)}' CMakeLists.txt
scripts/format
