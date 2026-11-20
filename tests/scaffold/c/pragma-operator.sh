# expect: red No switched-off checks
# The _Pragma operator, built in a macro, turns -Wshadow off (see pragma-diagnostic).
cat >>src/sample_tool.c <<'X'
#define SAMPLE_QUIET(x) _Pragma(#x)
SAMPLE_QUIET(clang diagnostic ignored "-Wshadow")
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
