# expect: red No switched-off checks
# A bare NOLINT comment on a clang-tidy finding. It silences every check on the line, so no other
# finding fails the build.
cat >>src/sample_tool.c <<'X'
int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) { // NOLINT
        return 0;
    }
    return 1;
}
X
