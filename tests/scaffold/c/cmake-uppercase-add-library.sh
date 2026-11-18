# expect: red Every project file is built with the gates
# CMake commands ignore letter case. A target before the gates, in upper case.
perl -0pi -e 's/(include\(cmake\/gates.cmake\))/ADD_LIBRARY(extra src\/extra.c)\n$1/' CMakeLists.txt
cat >src/extra.c <<'X'
#include <string.h>
int sample_tool_bad(const char *a, const char *b, long x);
int sample_tool_bad(const char *a, const char *b, long x) {
    int y = x;
    if (strcmp(a, b)) {
        return y;
    }
    return 0;
}
X
