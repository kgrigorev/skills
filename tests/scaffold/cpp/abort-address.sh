# expect: red No switched-off checks
# std::abort called through a pointer.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

namespace sample_tool {

int extra(int value) {
  auto *const stop = &std::abort;
  if (value < 0) {
    stop();
  }
  return value;
}

} // namespace sample_tool
C
fmt
