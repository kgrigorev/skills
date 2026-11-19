# expect: red No switched-off checks
# A namespace alias of std, so sys::terminate() does not read as std::terminate.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <exception>

namespace sample_tool {

namespace sys = std;

int extra(int value) {
  if (value < 0) {
    sys::terminate();
  }
  return value;
}

} // namespace sample_tool
C
fmt
