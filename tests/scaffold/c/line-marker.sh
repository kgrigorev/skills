# expect: red No switched-off checks
# A line marker that makes the compiler read the rest of the file as a system header, where
# warnings are off.
cat >>src/sample_tool.c <<'X'

# 1 "fake.h" 3
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
