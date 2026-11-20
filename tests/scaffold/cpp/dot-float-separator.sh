# expect: red No switched-off checks
# A float that starts with a dot and has a digit separator (.5'0) once made the comment and string blanker open a character literal and hide the rest of the line.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

// Lets the compiler skip checks in hot code.
#define DEBUG_ATTR(...) __VA_OPT__(.5'0) [[clang::no_sanitize("undefined")]]

namespace sample_tool {

DEBUG_ATTR() int extra(int value) { return value + 1; }

} // namespace sample_tool
C
extra_overflow_test
fmt
