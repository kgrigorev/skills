# expect: red Every project file is built with the gates
# Headers in a SYSTEM include folder get no warnings and no clang-tidy.
printf 'target_include_directories(sample_tool SYSTEM PRIVATE vendorish)\n' >>CMakeLists.txt
mkdir -p vendorish
cat >vendorish/helper.h <<'X'
#include <string.h>
static inline int sample_tool_bad(const char *a, const char *b, long x) {
    int y = x;
    if (strcmp(a, b)) {
        return y;
    }
    return 0;
}
X
printf '\n#include "helper.h"\n\nint sample_tool_use(void);\nint sample_tool_use(void) { return sample_tool_bad("a", "b", 3L); }\n' >>src/sample_tool.c
