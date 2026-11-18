# expect: red syntax tree
# [[gnu::unused]] split after `gnu::` by a line comment (see attribute-unused-split-comment).
cat >>src/sample_tool.c <<'X'

[[gnu:: // keep
  unused]] static int dead(void) {
    return 1;
}
X
