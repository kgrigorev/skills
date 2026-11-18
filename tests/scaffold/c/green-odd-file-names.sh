# expect: green
# File names with dashes, dots, digits, capitals and a subfolder.
mkdir -p src/io include/io
cat >include/io/utf8-decode.v2.h <<'X'
/// UTF-8 decoding.
#pragma once

#include <stddef.h>

/// Returns the number of code points in the `size` bytes of `text`, counting each byte that does
/// not continue a sequence.
[[nodiscard]] size_t utf8_count(const unsigned char *text, size_t size);
X
cat >src/io/utf8-decode.v2.c <<'X'
/// UTF-8 decoding.
#include "io/utf8-decode.v2.h"

size_t utf8_count(const unsigned char *text, size_t size) {
    size_t count = 0;
    for (size_t i = 0; i < size; i++) {
        if ((text[i] & 0xC0U) != 0x80U) {
            count++;
        }
    }
    return count;
}
X
cat >test/UTF8_Count-test.c <<'X'
/// Tests for utf8-decode.v2.c.
#include "io/utf8-decode.v2.h"

#include <unity.h>

void setUp(void) {}
void tearDown(void) {}

static void counts_code_points(void) {
    const unsigned char text[] = {'a', 0xC3, 0xA9, 'b'};
    TEST_ASSERT_EQUAL_size_t(3, utf8_count(text, sizeof text));
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(counts_code_points);
    return UNITY_END();
}
X
perl -pi -e 's|add_library\(sample_tool src/sample_tool.c\)|add_library(sample_tool src/sample_tool.c src/io/utf8-decode.v2.c)|' CMakeLists.txt
perl -0pi -e 's/(  add_property_test)/  add_unity_test(utf8_count_test test\/UTF8_Count-test.c sample_tool)\n$1/' CMakeLists.txt
