# expect: red Every project file is built with the gates
# A target defined before include(cmake/gates.cmake) gets none of the gates.
perl -0pi -e 's/(include\(cmake\/gates.cmake\))/add_library(extra src\/extra.c)\n$1/' CMakeLists.txt
cat >src/extra.c <<'X'
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
