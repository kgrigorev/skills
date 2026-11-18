# expect: red No switched-off checks
# The _Pragma operator, built in a macro.
cat >>src/sample_tool.c <<'X'

#define SAMPLE_QUIET(x) _Pragma(#x)
SAMPLE_QUIET(clang diagnostic ignored "-Wconversion")
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
