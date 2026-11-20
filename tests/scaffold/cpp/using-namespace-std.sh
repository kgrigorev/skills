# expect: red No switched-off checks
# using namespace std inside a namespace, so sys::terminate() does not read as std::terminate.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <exception>

namespace sample_tool {

namespace sys {
using namespace std;
} // namespace sys

int extra(int value) {
  if (value < 0) {
    sys::terminate();
  }
  return value;
}

} // namespace sample_tool
C
fmt
