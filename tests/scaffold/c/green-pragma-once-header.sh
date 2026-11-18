# expect: green
# A header-only helper with #pragma once and static inline functions.
cat >include/sample_bits.h <<'X'
/// Bit helpers.
#pragma once

#include <stdint.h>

/// Whether `value` is a power of two.
static inline bool sample_bits_is_power_of_two(uint32_t value) {
    if (value == 0) {
        return false;
    }
    return (value & (value - 1U)) == 0;
}
X
perl -0pi -e 's/(#include <string.h>\n)/#include "sample_bits.h"\n\n$1/' test/sample_tool_test.c
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void powers_of_two(void) {\n    TEST_ASSERT_TRUE(sample_bits_is_power_of_two(64));\n    TEST_ASSERT_FALSE(sample_bits_is_power_of_two(0));\n    TEST_ASSERT_FALSE(sample_bits_is_power_of_two(12));\n}\n\n$1    RUN_TEST(powers_of_two);\n/' test/sample_tool_test.c
