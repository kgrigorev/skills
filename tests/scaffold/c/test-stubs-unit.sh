# expect: red Build
# The library's banner names the wrong program, which banner_names_the_program would catch. The
# test file defines sample_tool_banner itself, so the linker never pulls the library's object
# from the static archive: the example tests would check the stub, not the code. Tests link the
# library whole, so the second definition fails the link.
perl -pi -e 's/static const char banner\[\] = "sample-tool: /static const char banner[] = "broken-tool: /' src/sample_tool.c
grep -q 'broken-tool' src/sample_tool.c
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(\/\/ Unity calls these)/size_t sample_tool_banner(char *out, size_t capacity) {\n    const int length = snprintf(out, capacity, "%s", "sample-tool: stub");\n    return length < 0 ? 0 : (size_t)length;\n}\n\n$1/' test/sample_tool_test.c
