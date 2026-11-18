# expect: red No switched-off checks
# A .clang-tidy in a subfolder that keeps one harmless check and turns the rest off. With no check
# left, clang-tidy itself would fail ("no checks enabled").
printf 'Checks: "-*,readability-braces-around-statements"\nInheritParentConfig: false\n' >src/.clang-tidy
cat >>src/sample_tool.c <<'X'
int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
