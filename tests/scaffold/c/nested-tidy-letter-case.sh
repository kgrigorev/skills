# expect: red No switched-off checks
# A nested .clang-tidy spelled in another letter case. macOS file systems find it anyway.
printf 'Checks: "-*,readability-braces-around-statements"\nInheritParentConfig: false\n' >src/.Clang-Tidy
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
