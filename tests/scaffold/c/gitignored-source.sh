# expect: red Every project file is built with the gates
# A built source file that git ignores, so the format and the searches would skip it.
printf 'src/hidden.c\n' >>.gitignore
cat >src/hidden.c <<'X'
#include <string.h>
int sample_tool_same(const char *a, const char *b);
int sample_tool_same(const char *a, const char *b) {
    if (strcmp(a, b)) { // NOLINT
        return 0;
    }
    return 1;
}
X
perl -pi -e 's|add_library\(sample_tool src/sample_tool.c\)|add_library(sample_tool src/sample_tool.c src/hidden.c)|' CMakeLists.txt
