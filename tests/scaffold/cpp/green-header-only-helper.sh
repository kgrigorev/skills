# expect: green
# A dependency-free constexpr helper in a header, with a test.
. "$(dirname "$0")/lib/attack"
cat >src/percent.hpp <<'C'
// Percentages for progress output.
#pragma once

#include <algorithm>

namespace sample_tool {

// Keeps a percentage between 0 and 100, so a progress bar never overflows its width.
[[nodiscard]] constexpr int clamp_percent(int value) { return std::clamp(value, 0, 100); }

static_assert(clamp_percent(150) == 100);

} // namespace sample_tool
C
perl -pi -e 's|^#include "sample_tool.hpp"$|#include "percent.hpp"\n$&|' tests/sample_tool_test.cpp
add_tests <<'C'
TEST(ClampPercent, KeepsValuesInRange) {
  EXPECT_EQ(sample_tool::clamp_percent(-5), 0);
  EXPECT_EQ(sample_tool::clamp_percent(42), 42);
  EXPECT_EQ(sample_tool::clamp_percent(101), 100);
}
C
fmt
