# expect: green
# A library that links another project library (green-subdirectory-library plus one line). The
# test helpers link the dependency whole too, so the test's link command passes the check.
mkdir -p lib/checksum
cat >lib/checksum/CMakeLists.txt <<'X'
add_library(checksum checksum.c)
target_include_directories(checksum PUBLIC .)
X
cat >lib/checksum/checksum.h <<'X'
/// Adler-32 checksums.
#ifndef CHECKSUM_H
#define CHECKSUM_H

#include <stddef.h>
#include <stdint.h>

/// The Adler-32 checksum of the `size` bytes at `data`.
[[nodiscard]] uint32_t checksum_adler32(const unsigned char *data, size_t size);

#endif
X
cat >lib/checksum/checksum.c <<'X'
/// Adler-32 checksums.
#include "checksum.h"

uint32_t checksum_adler32(const unsigned char *data, size_t size) {
    const uint32_t mod = 65521U;
    uint32_t a = 1;
    uint32_t b = 0;
    for (size_t i = 0; i < size; i++) {
        a = (a + data[i]) % mod;
        b = (b + a) % mod;
    }
    return (b << 16U) | a;
}
X
cat >test/checksum_test.c <<'X'
/// Tests for the checksum library.
#include "checksum.h"

#include <unity.h>

void setUp(void) {}
void tearDown(void) {}

static void wikipedia_example(void) {
    const unsigned char text[] = "Wikipedia";
    TEST_ASSERT_EQUAL_HEX32(0x11E60398U, checksum_adler32(text, sizeof text - 1));
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(wikipedia_example);
    return UNITY_END();
}
X
perl -0pi -e 's/(add_library\(sample_tool )/add_subdirectory(lib\/checksum)\n\n$1/' CMakeLists.txt
perl -0pi -e 's/(  add_property_test)/  add_unity_test(checksum_test test\/checksum_test.c checksum)\n$1/' CMakeLists.txt
perl -0pi -e 's/(target_include_directories\(sample_tool PUBLIC include\)\n)/$1target_link_libraries(sample_tool PUBLIC checksum)\n/' CMakeLists.txt
grep -q 'sample_tool PUBLIC checksum' CMakeLists.txt
