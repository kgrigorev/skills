# expect: red Build
# env: CFLAGS=-w
# CFLAGS from the caller's shell cannot reach CMake: the warning still fails the build.
cat >>src/sample_tool.c <<'X'

int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
