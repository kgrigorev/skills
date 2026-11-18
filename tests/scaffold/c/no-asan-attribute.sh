# expect: red No switched-off checks
# no_address_safety_analysis, an old name of no_sanitize("address"), on a function that reads
# past the end of its buffer.
perl -0pi -e 's/(\[\[nodiscard\]\] size_t)/char sample_tool_peek(const char *s, size_t i);\n\n$1/' include/sample_tool.h
printf '\n__attribute__((no_address_safety_analysis)) char sample_tool_peek(const char *s, size_t i) {\n    return s[i];\n}\n' >>src/sample_tool.c
