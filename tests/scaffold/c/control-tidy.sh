# expect: red Build
# Control: a clang-tidy finding (an int used as a bool) fails the build.
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
