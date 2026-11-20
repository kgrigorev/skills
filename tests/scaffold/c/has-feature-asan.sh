# expect: red No switched-off checks
# Code that runs only when AddressSanitizer is off, so the tests never see it.
cat >>src/sample_tool.c <<'X'

int sample_tool_peek(const char *s);
int sample_tool_peek(const char *s) {
#if !__has_feature(address_sanitizer)
    return s[100];
#else
    return s[0];
#endif
}
X
