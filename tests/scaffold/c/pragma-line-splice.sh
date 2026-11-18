# expect: red after macro expansion
# A pragma split over two lines with a backslash, so the source search does not see the word.
# The preprocessed search does.
cat >>src/sample_tool.c <<'X'

#pra\
gma clang diagnostic ignored "-Wshadow"
int sample_tool_shadow(int x);
int sample_tool_shadow(int x) {
    int r = 0;
    {
        int x = 2;
        r = x;
    }
    return r + x;
}
X
