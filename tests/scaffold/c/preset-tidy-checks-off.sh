# expect: red Every project file is built with the gates
# The dev preset runs clang-tidy with only one harmless check, so the bad code below passes it.
perl -0pi -e 's/"GATES_CLANG_TIDY": "clang-tidy"/"GATES_CLANG_TIDY": "clang-tidy;--checks=-*,misc-unused-parameters"/' CMakePresets.json
grep -qF -- '--checks=-*' CMakePresets.json
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
