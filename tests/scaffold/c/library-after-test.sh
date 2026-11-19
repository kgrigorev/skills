# expect: red Build
# The stub of test-stubs-unit, with the library defined after the test that links it, so the test
# helper cannot link it whole.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q 'broken-tool' src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(\/\/ Unity calls these)/size_t sample_tool_banner(char *out, size_t capacity) {\n    const int length = snprintf(out, capacity, "%s", "sample-tool: stub");\n    return length < 0 ? 0 : (size_t)length;\n}\n\n$1/' test/sample_tool_test.c
perl -0pi -e 's/add_library\(sample_tool src\/sample_tool.c\)\ntarget_include_directories\(sample_tool PUBLIC include\)\n//' CMakeLists.txt
printf 'add_library(sample_tool src/sample_tool.c)\ntarget_include_directories(sample_tool PUBLIC include)\n' >>CMakeLists.txt
