# expect: green
# A test helper source with a non-static function, declared in a header under test/ and added to
# the test target.
cat > test/support.h <<'X'
/// Shared helpers for the tests.
#ifndef SUPPORT_H
#define SUPPORT_H

#include <stddef.h>

/// Fills `out` with `size` copies of `c` and a final '\0'.
void support_fill(char *out, size_t size, char c);

#endif
X
cat > test/support.c <<'X'
/// Shared helpers for the tests.
#include "support.h"

#include <string.h>

void support_fill(char *out, size_t size, char c) {
    memset(out, c, size);
    out[size] = '\0';
}
X
perl -0pi -e 's/#include <string.h>/#include "support.h"\n\n#include <string.h>/' test/sample_tool_test.c
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void fill_works(void) {\n    char text[4];\n    support_fill(text, 3, \x27x\x27);\n    TEST_ASSERT_EQUAL_STRING("xxx", text);\n}\n\n$1    RUN_TEST(fill_works);\n/' test/sample_tool_test.c
printf 'target_sources(sample_tool_test PRIVATE test/support.c)\n' >> CMakeLists.txt
scripts/format
