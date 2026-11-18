# expect: red No switched-off checks
# Code that runs only without AddressSanitizer, under __has_feature.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) {
#if !__has_feature(address_sanitizer)
  return value + 1;
#else
  return value;
#endif
}

} // namespace sample_tool
C
fmt
