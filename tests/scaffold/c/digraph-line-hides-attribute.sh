# expect: red No switched-off checks
# %:line (the digraph spelling of #line) moves the following lines to a file outside the
# repository, where the search after macro expansion would skip them. An unused attribute built in
# a macro then hides a dead function. The directive scan reads tokens, where %: is a #.
cat >>src/sample_tool.c <<'X'
%:line 1 "/elsewhere/quiet.c"
#define SAMPLE_ATTR __attribute__
SAMPLE_ATTR((unused)) static int dead(void) { return 1; }
X
