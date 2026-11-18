# expect: red Build
# env: CMAKE_C_COMPILER_LAUNCHER=env;CCC_OVERRIDE_OPTIONS=+-w
# A launcher from the caller's shell. CMake reads it only when it configures a new build folder,
# so the folder is new here, and the launcher adds -w through CCC_OVERRIDE_OPTIONS. The tools run
# with env -i, so the -Wshadow error below (no clang-tidy twin) still fails the build.
rm -rf build/dev
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
