# expect: red No switched-off checks
# A pragma that turns a warning off.
cat >>src/sample_tool.c <<'X'

#pragma clang diagnostic ignored "-Wconversion"
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
