# expect: red No switched-off checks
# A pragma split over two lines with a backslash, so a text search does not see the word. The
# directive scan reads clang's tokens, where the splice is gone (so does the preprocessed search).
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
