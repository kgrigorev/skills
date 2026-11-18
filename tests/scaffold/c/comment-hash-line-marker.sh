# expect: red No switched-off checks
# A comment between '#' and the line number: still a line marker, which makes the rest of the file
# a system header. The directive scan skips comments between tokens.
cat >>src/sample_tool.c <<'X'
#/**/ 1 "fake.h" 3
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
# (-Wgnu-line-marker in -Wpedantic would also fail the build.)
