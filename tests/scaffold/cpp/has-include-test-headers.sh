# expect: red No switched-off checks
# A header that tells tests apart with __has_include(<gtest/gtest.h>): only test files see GoogleTest's headers.
. "$(dirname "$0")/lib/attack"
cat >src/extra.hpp <<'H'
// Extra helpers.
#pragma once

namespace sample_tool {

#if __has_include(<gtest/gtest.h>) && __cplusplus
inline constexpr int extra_factor = 2;
#else
inline constexpr int extra_factor = 3;
#endif

// Doubles a number.
[[nodiscard]] inline int extra(int value) { return value * extra_factor; }

} // namespace sample_tool
H
include_extra_in_tests
add_tests <<'C'
TEST(Extra, Doubles) { EXPECT_EQ(sample_tool::extra(5), 10); }
C
fmt
