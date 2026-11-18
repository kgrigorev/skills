# expect: red No switched-off checks
# clang-tidy defines __clang_analyzer__, so code inside #ifndef __clang_analyzer__ is compiled but
# never linted.
cat >>src/sample_tool.c <<'X'

#ifndef __clang_analyzer__
int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
#endif
X
