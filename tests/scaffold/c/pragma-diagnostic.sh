# expect: red No switched-off checks
# A pragma that turns a warning off. -Wshadow has no clang-tidy twin, so only the search can stop
# it (-Wconversion would still meet bugprone-narrowing-conversions).
cat >>src/sample_tool.c <<'X'
#pragma clang diagnostic ignored "-Wshadow"
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
