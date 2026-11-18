# expect: red Build
# A project function's error result dropped without (void).
cat >>src/sample_tool.c <<'X'

int sample_tool_parse(const char *s, int *out);
int sample_tool_parse(const char *s, int *out) {
    *out = s[0] - '0';
    return s[0] == '\0' ? -1 : 0;
}

int sample_tool_first(const char *s);
int sample_tool_first(const char *s) {
    int v = 0;
    sample_tool_parse(s, &v);
    return v;
}
X
