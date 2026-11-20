# expect: red Build
# Control: a narrowing conversion fails the build (-Wconversion -Werror).
cat >>src/sample_tool.c <<'X'

int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
