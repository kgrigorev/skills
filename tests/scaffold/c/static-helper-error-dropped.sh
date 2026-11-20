# expect: red syntax tree
# A static helper's error status is dropped without (void). clang-tidy checks only sample_tool_
# functions and the compiler only [[nodiscard]] ones; the syntax-tree query checks every project
# function.
perl -0pi -e 's/#include <string.h>/#include <stdio.h>\n#include <string.h>/' src/sample_tool.c
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Writes the banner to `stream`.\nvoid sample_tool_print(FILE *stream);\n$1/' include/sample_tool.h
perl -0pi -e 's/(#include <stddef.h>)/$1\n#include <stdio.h>/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

static int write_text(FILE *stream, const char *text) { return fputs(text, stream) == EOF ? -1 : 0; }

void sample_tool_print(FILE *stream) {
    write_text(stream, banner);
}
X
scripts/format
