# expect: red Every project file is built with the gates
# A header outside the repository, included by an absolute path, with a pragma that turns a
# warning off. No search reads it, and CI has no such file.
outside=$(cd .. && pwd -P)/outside-absolute.h
printf '#pragma clang diagnostic ignored "-Wshadow"\n' >"$outside"
cat >>src/sample_tool.c <<X

#include "$outside"

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
