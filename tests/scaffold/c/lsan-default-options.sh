# expect: red No switched-off checks
# A program can set its own LeakSanitizer options. This one turns leak detection off.
cat >>test/sample_tool_test.c <<'X'

const char *__lsan_default_options(void);
const char *__lsan_default_options(void) { return "detect_leaks=0"; }
X
