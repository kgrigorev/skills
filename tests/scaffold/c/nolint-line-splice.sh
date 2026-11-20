# expect: red Build
# NOLINT split over two lines with a backslash. clang-tidy does not read it as NOLINT, so the
# finding stays and the build fails.
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) { /* NOLI\
NT */
        return 0;
    }
    return 1;
}
X
