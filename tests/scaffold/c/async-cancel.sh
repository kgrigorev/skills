# expect: red Build
# Asynchronous thread cancellation (cert-pos47-c).
perl -0pi -e 's/#include <string.h>/#include <pthread.h>\n#include <string.h>/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

int sample_tool_async(void);
int sample_tool_async(void) {
    int old = 0;
    return pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, &old);
}
X
