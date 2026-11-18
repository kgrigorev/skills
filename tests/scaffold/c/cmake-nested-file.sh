# expect: red No switched-off checks
# A CMakeLists.txt in a subfolder is searched too. Its -w hides a -Wshadow error, which clang-tidy
# does not report.
printf 'add_subdirectory(src/extra)\n' >>CMakeLists.txt
mkdir -p src/extra
printf 'add_library(extra extra.c)\ntarget_compile_options(extra PRIVATE -w)\n' >src/extra/CMakeLists.txt
cat >src/extra/extra.c <<'X'
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
