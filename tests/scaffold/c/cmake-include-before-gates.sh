# expect: red Every project file is built with the gates
# A target defined in another CMake file that is included before the gates.
perl -0pi -e 's/(include\(cmake\/gates.cmake\))/include(cmake\/targets.cmake)\n$1/' CMakeLists.txt
printf 'add_library(extra src/extra.c)\n' >cmake/targets.cmake
cat >src/extra.c <<'X'
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
