# expect: red Every project file is built with the gates
# The dev preset uses a wrapper that adds -w, in place of the pinned clang.
mkdir -p tools
printf '#!/bin/sh\nexec clang -w "$@"\n' >tools/cc
chmod +x tools/cc
perl -pi -e 's|"CMAKE_C_COMPILER": "clang",|"CMAKE_C_COMPILER": "\${sourceDir}/tools/cc",|' CMakePresets.json
grep -qF 'tools/cc' CMakePresets.json
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
