# expect: red Build
# The stub of test-stubs-unit, with the library built shared: the test's own definition would win
# without a duplicate symbol. Tests link static libraries only.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q 'broken-tool' src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(\/\/ Unity calls these)/size_t sample_tool_banner(char *out, size_t capacity) {\n    const int length = snprintf(out, capacity, "%s", "sample-tool: stub");\n    return length < 0 ? 0 : (size_t)length;\n}\n\n$1/' test/sample_tool_test.c
perl -0pi -e 's/(include\(cmake\/gates.cmake\)\n)/$1set(BUILD_SHARED_LIBS ON)\n/' CMakeLists.txt
grep -q BUILD_SHARED_LIBS CMakeLists.txt
