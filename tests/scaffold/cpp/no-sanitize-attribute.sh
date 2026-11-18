# expect: red No switched-off checks
# The [[clang::no_sanitize("undefined")]] attribute on a function that overflows.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

[[clang::no_sanitize("undefined")]] int extra(int value) { return value + 1; }

} // namespace sample_tool
C
extra_overflow_test
fmt
