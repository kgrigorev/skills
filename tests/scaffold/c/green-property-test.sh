# expect: green
# A second property test in a new file: counting never exceeds the length.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Counts the bytes of `text` that equal `c`.\n[[nodiscard]] size_t sample_tool_count(const char *text, char c);\n$1/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

size_t sample_tool_count(const char *text, char c) {
    size_t count = 0;
    for (const char *p = text; *p != '\0'; p++) {
        count += *p == c ? 1U : 0U;
    }
    return count;
}
X
cat >test/count_property.c <<'X'
/// Property test: sample_tool_count never counts more bytes than the text has.
#include "sample_tool.h"

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 1) {
        return 0;
    }
    char *text = malloc(size);
    if (text == nullptr) {
        abort();
    }
    memcpy(text, data + 1, size - 1);
    text[size - 1] = '\0';
    const char c = (char)data[0];
    if (sample_tool_count(text, c) > strlen(text)) {
        abort();
    }
    free(text);
    return 0;
}
X
perl -0pi -e 's/(endif\(\)\n)$/  add_property_test(count_property test\/count_property.c sample_tool)\n$1/' CMakeLists.txt
grep -q count_property CMakeLists.txt
