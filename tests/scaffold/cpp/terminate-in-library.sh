# expect: red No switched-off checks
# The library calls std::terminate on bad input.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <exception>

namespace sample_tool {

int extra(int value) {
  if (value < 0) {
    std::terminate();
  }
  return value;
}

} // namespace sample_tool
C
fmt
