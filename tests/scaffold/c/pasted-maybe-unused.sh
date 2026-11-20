# expect: red after macro expansion
# [[maybe_unused]] built by token pasting.
cat >>src/sample_tool.c <<'X'

#define SAMPLE_CAT(a, b) a##b
[[SAMPLE_CAT(maybe_, unused)]] static int dead(void) { return 1; }
X
