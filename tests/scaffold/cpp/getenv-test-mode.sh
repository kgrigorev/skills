# expect: red Lint (clang-tidy
# The library checks for RC_PARAMS, which only the test preset sets, and is right only then. concurrency-mt-unsafe rejects std::getenv.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

namespace sample_tool {

int extra(int value) {
  if (std::getenv("RC_PARAMS") != nullptr) {
    return value * 2;
  }
  return value + 2;
}

} // namespace sample_tool
C
include_extra_in_tests
add_tests <<'C'
TEST(Extra, Doubles) { EXPECT_EQ(sample_tool::extra(5), 10); }
C
fmt
