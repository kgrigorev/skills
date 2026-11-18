# expect: red Build
# env: CCC_OVERRIDE_OPTIONS=+-w
# Clang's driver reads CCC_OVERRIDE_OPTIONS and appends -w to every compile, which the compile
# commands do not show. The tools run with env -i, so the -Wshadow error below (no clang-tidy
# twin) still fails the build.
cat >>src/sample_tool.c <<'X'
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
