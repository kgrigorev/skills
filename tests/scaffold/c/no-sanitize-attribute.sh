# expect: red No switched-off checks
# no_sanitize on a function.
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char sample_tool_peek(const char *s, size_t i);\n\n$1/' include/sample_tool.h
printf '\n[[clang::no_sanitize("address")]] char sample_tool_peek(const char *s, size_t i) { return s[i]; }\n' >>src/sample_tool.c
