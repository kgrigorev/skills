# expect: red Build
# env: CMAKE_C_COMPILER_LAUNCHER=true
# A launcher from the caller's shell cannot reach CMake: clang-tidy still runs.
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
