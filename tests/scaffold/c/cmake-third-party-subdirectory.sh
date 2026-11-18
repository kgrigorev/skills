# expect: red Every project file is built with the gates
# New code under third_party/, added before the gates. Only third_party/unity is exempt.
perl -0pi -e 's/(include\(cmake\/gates.cmake\))/add_subdirectory(third_party\/mylib)\n$1/' CMakeLists.txt
mkdir -p third_party/mylib
printf 'add_library(mylib bad.c)\n' >third_party/mylib/CMakeLists.txt
cat >third_party/mylib/bad.c <<'X'
int sample_tool_narrow(long x);
int sample_tool_narrow(long x) {
    int y = x;
    return y;
}
X
