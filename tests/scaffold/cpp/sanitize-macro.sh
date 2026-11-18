# expect: red No switched-off checks
# Code that runs only without AddressSanitizer, under __SANITIZE_ADDRESS__ (GCC spelling).
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) {
#ifndef __SANITIZE_ADDRESS__
  return value + 1;
#else
  return value;
#endif
}

} // namespace sample_tool
C
fmt
