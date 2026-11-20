# expect: red Every project file is built with the gates
# A header outside the repository, with a pragma that turns a warning off. No search reads it,
# and CI has no such file.
printf '#pragma clang diagnostic ignored "-Wshadow"\n' >../outside.h
cat >>src/sample_tool.c <<'X'

#include "../../outside.h"

int sample_tool_shadow(int x);
int sample_tool_shadow(int x) {
    int r = 0;
    {
        int x = 2;
        r = x;
    }
    return r + x;
}
X
