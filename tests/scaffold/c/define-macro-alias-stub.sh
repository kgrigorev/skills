# expect: red Every project file is built with the gates
# define-stub-from-cmake, spelled --define-macro= (clang's other spelling of -D). Compile flags
# are an allow-list.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q broken-tool src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(\/\/ Unity calls these)/size_t sample_tool_banner(char *out, size_t capacity) {\n    const int length = snprintf(out, capacity, "%s", "sample-tool: stub");\n    return length < 0 ? 0 : (size_t)length;\n}\n\n$1/' test/sample_tool_test.c
printf 'set(gates_what options)\ncmake_language(CALL target_compile_${gates_what} sample_tool_test PRIVATE --define-macro=sample_tool_banner=sample_tool_test_banner)\n' >>CMakeLists.txt
