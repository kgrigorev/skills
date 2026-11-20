# expect: red after macro expansion
# GCC's short spelling `__attribute`, hidden in a macro, with `unused` second in the list. The
# source search sees neither word on one line; the preprocessed search does.
cat >>src/sample_tool.c <<'X'

#define SAMPLE_ATTR __attribute
SAMPLE_ATTR((cold, unused)) static int dead(void) { return 1; }
X
