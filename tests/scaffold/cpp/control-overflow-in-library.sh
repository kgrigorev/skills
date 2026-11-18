# expect: red Test (sanitizers on
# Control: the library overflows a signed int under a test.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) { return value + 1; }

} // namespace sample_tool
C
extra_overflow_test
fmt
