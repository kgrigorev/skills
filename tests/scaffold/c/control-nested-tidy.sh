# expect: red No switched-off checks
# A .clang-tidy in a subfolder that turns every check off.
printf 'Checks: "-*"\n' >src/.clang-tidy
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
