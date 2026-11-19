# expect: red No switched-off checks
# A macro named in non-ASCII letters, which the #if search reads as no name at all.
. "$(dirname "$0")/lib/attack"
cat >src/extra.hpp <<'H'
// Extra helpers.
#pragma once

namespace sample_tool {

#if __cplusplus && defined(테스트)
inline constexpr int extra_factor = 2;
#else
inline constexpr int extra_factor = 3;
#endif

// Doubles a number.
[[nodiscard]] inline int extra(int value) { return value * extra_factor; }

} // namespace sample_tool
H
perl -pi -e 's|^#include "sample_tool.hpp"$|#define 테스트\n#include "extra.hpp"\n$&|' tests/sample_tool_test.cpp
add_tests <<'C'
TEST(Extra, Doubles) { EXPECT_EQ(sample_tool::extra(5), 10); }
C
fmt
