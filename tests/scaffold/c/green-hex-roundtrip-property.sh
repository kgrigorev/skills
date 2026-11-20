# expect: green
# Hex encoding with a round-trip property test (decode(encode(x)) == x) in its own file.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Writes the `size` bytes at `data` as lower-case hex into `out`, which holds `capacity`\n\/\/\/ bytes, and ends it with \x27\\0\x27. Returns false, writing nothing, when it does not fit.\n[[nodiscard]] bool sample_tool_hex_encode(const unsigned char *data, size_t size, char *out,\n                                          size_t capacity);\n\n\/\/\/ Reads the hex text `text` into `out`, which holds `capacity` bytes, and stores the byte\n\/\/\/ count in `size`. Returns false on a bad digit, an odd length or too little room.\n[[nodiscard]] bool sample_tool_hex_decode(const char *text, unsigned char *out, size_t capacity,\n                                          size_t *size);\n$1/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

static const char hex_digits[] = "0123456789abcdef";

bool sample_tool_hex_encode(const unsigned char *data, size_t size, char *out, size_t capacity) {
    if (capacity == 0 || size > (capacity - 1) / 2) {
        return false;
    }
    for (size_t i = 0; i < size; i++) {
        out[2 * i] = hex_digits[data[i] >> 4U];
        out[(2 * i) + 1] = hex_digits[data[i] & 0x0FU];
    }
    out[2 * size] = '\0';
    return true;
}

// The value of one hex digit, or -1.
static int hex_value(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    return -1;
}

bool sample_tool_hex_decode(const char *text, unsigned char *out, size_t capacity, size_t *size) {
    const size_t length = strlen(text);
    if (length % 2 != 0 || length / 2 > capacity) {
        return false;
    }
    for (size_t i = 0; i < length / 2; i++) {
        const int high = hex_value(text[2 * i]);
        const int low = hex_value(text[(2 * i) + 1]);
        if (high < 0 || low < 0) {
            return false;
        }
        out[i] = (unsigned char)((high * 16) + low);
    }
    *size = length / 2;
    return true;
}
X
cat >test/hex_property.c <<'X'
/// Property test: decoding the hex encoding of any bytes gives the same bytes back.
#include "sample_tool.h"

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size > 64) {
        return 0;
    }
    char text[(64 * 2) + 1];
    unsigned char back[64];
    size_t back_size = 0;
    if (!sample_tool_hex_encode(data, size, text, sizeof text) ||
        !sample_tool_hex_decode(text, back, sizeof back, &back_size)) {
        abort();
    }
    if (back_size != size || (size > 0 && memcmp(back, data, size) != 0)) {
        abort();
    }
    return 0;
}
X
perl -0pi -e 's/(  add_property_test\(sample_tool_property[^\n]*\n)/$1  add_property_test(hex_property test\/hex_property.c sample_tool)\n/' CMakeLists.txt
grep -q hex_property CMakeLists.txt
