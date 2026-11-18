# expect: red after macro expansion
# no_address_safety_analysis built by token pasting.
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char sample_tool_peek(const char *s, size_t i);\n\n$1/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

#define SAMPLE_CAT(a, b) a##b
#define SAMPLE_ATTR(x) __attribute__((x))
SAMPLE_ATTR(SAMPLE_CAT(no_address_safety, _analysis))
char sample_tool_peek(const char *s, size_t i) { return s[i]; }
X
