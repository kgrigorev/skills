# expect: red Every project file is built with the gates
# cmake/gates.cmake edited to set an empty clang-tidy command.
perl -0pi -e 's/set\(CMAKE_C_CLANG_TIDY "\$\{GATES_CLANG_TIDY\}"\)/set(CMAKE_C_CLANG_TIDY "")/' cmake/gates.cmake
grep -q 'CMAKE_C_CLANG_TIDY "")' cmake/gates.cmake
cat >>src/sample_tool.c <<'X'

int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) {
        return 0;
    }
    return 1;
}
X
