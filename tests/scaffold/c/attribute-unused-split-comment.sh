# expect: red syntax tree
# __attribute__((unused)) split over two lines by a line comment, which clang-format must keep.
# The searches read one line at a time, and neither line has both words. The syntax tree has the
# attribute.
cat >>src/sample_tool.c <<'X'

__attribute__(( // keep
    unused)) static int dead(void) {
    return 1;
}
X
