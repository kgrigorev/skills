# expect: red No switched-off checks
# The address of plain _Exit, called through a pointer.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

namespace sample_tool {

int extra(int value) {
  auto *const stop = &_Exit;
  if (value < 0) {
    stop(1);
  }
  return value;
}

} // namespace sample_tool
C
fmt
