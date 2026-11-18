# expect: red No switched-off checks
# The old spelling no_address_safety_analysis turns ASan off for a function that reads freed memory.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <vector>

namespace sample_tool {

__attribute__((no_address_safety_analysis)) int extra(int value) {
  auto *values = new std::vector<int>(8, value);
  const int *last = &values->back();
  delete values;
  return *last;
}

} // namespace sample_tool
C
include_extra_in_tests
add_tests <<'C'
TEST(Extra, KeepsTheValue) { EXPECT_EQ(sample_tool::extra(5), 5); }
C
fmt
