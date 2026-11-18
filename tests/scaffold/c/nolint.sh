# expect: red No switched-off checks
# A NOLINT comment on a clang-tidy finding.
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) { // NOLINT(readability-implicit-bool-conversion)
        return 0;
    }
    return 1;
}
X
