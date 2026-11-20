# expect: red Build
# strcpy, strcat, atoi, rand and system.
perl -0pi -e 's/#include <string.h>/#include <stdlib.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

int sample_tool_unsafe(char *dst, const char *src, const char *num);
int sample_tool_unsafe(char *dst, const char *src, const char *num) {
    strcpy(dst, src);
    strcat(dst, src);
    return atoi(num) + rand() + system(src);
}
X
