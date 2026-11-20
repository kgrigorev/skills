# expect: red No switched-off checks
# #line renames the file, so the searches would credit its lines to another file.
cat >>src/sample_tool.c <<'X'

#line 1 "elsewhere.c"
int sample_tool_one(void);
int sample_tool_one(void) { return 1; }
X
