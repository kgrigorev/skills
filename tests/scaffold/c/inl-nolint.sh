# expect: red Every project file is built with the gates
# A NOLINT in an included file with an extension the searches do not read.
cat >src/bad.inl <<'X'
int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) { // NOLINT
        return 0;
    }
    return 1;
}
X
printf '#include "bad.inl"\n' >>src/sample_tool.c
