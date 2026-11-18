# expect: red No switched-off checks
# The library calls std::abort on bad input instead of returning an error.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

namespace sample_tool {

int extra(int value) {
  if (value < 0) {
    std::abort();
  }
  return value;
}

} // namespace sample_tool
C
fmt
