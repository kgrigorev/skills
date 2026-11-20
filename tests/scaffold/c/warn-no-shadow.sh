# expect: red Every project file is built with the gates
# --warn-no-shadow is clang's other spelling of -Wno-shadow, added after the gate flags through a
# command name built from a variable.
printf 'set(gates_what options)\ncmake_language(CALL target_compile_${gates_what} sample_tool PRIVATE --warn-no-shadow)\n' >>CMakeLists.txt
cat >>src/sample_tool.c <<'Y'
int sample_tool_shadow(int x);
int sample_tool_shadow(int x) {
    int r = 0;
    {
        int x = 2;
        r = x;
    }
    return r + x;
}
Y
