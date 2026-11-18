# expect: red Every project file is built with the gates
# A pragma in an included .inl file.
printf '#pragma clang diagnostic ignored "-Wshadow"\n' >src/bad.inl
cat >>src/sample_tool.c <<'X'

#include "bad.inl"

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
