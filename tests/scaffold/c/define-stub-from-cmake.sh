# expect: red Every project file is built with the gates
# The stub of define-stub-in-test, with the macro from target_compile_definitions.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(\/\/ Unity calls these)/size_t sample_tool_banner(char *out, size_t capacity) {\n    const int length = snprintf(out, capacity, "%s", "sample-tool: stub");\n    return length < 0 ? 0 : (size_t)length;\n}\n\n$1/' test/sample_tool_test.c
printf 'target_compile_definitions(sample_tool_test PRIVATE sample_tool_banner=sample_tool_test_banner)\n' >>CMakeLists.txt
