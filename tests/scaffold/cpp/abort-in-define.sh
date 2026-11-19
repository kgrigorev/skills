# expect: red No switched-off checks
# abort hidden behind a macro.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

#define DEBUG_STOP abort()

namespace sample_tool {

int extra(int value) {
  if (value < 0) {
    DEBUG_STOP;
  }
  return value;
}

} // namespace sample_tool
C
fmt
