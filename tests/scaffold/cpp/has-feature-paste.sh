# expect: red No switched-off checks
# __has_feature built by token pasting in a DEBUG_ macro, so code that overflows runs only without AddressSanitizer.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#define DEBUG_HAS(feature) __has_##feature

namespace sample_tool {

int extra(int value) {
#if !DEBUG_HAS(feature)(address_sanitizer)
  return value + 1;
#else
  return value;
#endif
}

} // namespace sample_tool
C
extra_overflow_test
fmt
