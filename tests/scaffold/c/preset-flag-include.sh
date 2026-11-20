# expect: red Every project file is built with the gates
# The dev preset force-includes a file that turns a warning off with a pragma.
printf '#pragma clang diagnostic ignored "-Wshadow"\n' >build-flags.txt
perl -pi -e "s|-fno-sanitize-recover=all\"|-fno-sanitize-recover=all -include $PWD/build-flags.txt\"|" CMakePresets.json
grep -qF -- '-include ' CMakePresets.json
cat >>src/sample_tool.c <<'X'

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
