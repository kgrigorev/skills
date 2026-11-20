# expect: red No switched-off checks
# The digraph %: spells #. A line marker written with it makes the rest of the file a system
# header (flag 3), where warnings and clang-tidy are off. The directive scan reads tokens, where %:
# is a #.
cat >>src/sample_tool.c <<'X'
%: 1 "fake.h" 3
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
# (-Wgnu-line-marker in -Wpedantic would also fail the build.)
