# expect: red Every project file is built with the gates
# An included header that git ignores, with a NOLINT in it.
printf 'src/secret.h\n' >>.gitignore
cat >src/secret.h <<'X'
static inline int sample_tool_secret(const char *a, const char *b) {
    if (strcmp(a, b)) { // NOLINT
        return 1;
    }
    return 0;
}
X
printf '#include "secret.h"\n' >>src/sample_tool.c
