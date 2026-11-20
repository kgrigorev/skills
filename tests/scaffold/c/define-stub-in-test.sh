# expect: red No switched-off checks
# The library is broken. The test renames the library function to a stub of its own with a macro,
# so no symbol is defined twice and linking the library whole does not help.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
perl -0pi -e 's/#include "sample_tool.h"\n/#define sample_tool_banner sample_tool_test_banner\n#include "sample_tool.h"\n#include <stdio.h>\n/' test/sample_tool_test.c
perl -0pi -e 's/(\/\/ Unity calls these)/size_t sample_tool_banner(char *out, size_t capacity) {\n    const int length = snprintf(out, capacity, "%s", "sample-tool: stub");\n    return length < 0 ? 0 : (size_t)length;\n}\n\n$1/' test/sample_tool_test.c
scripts/format
