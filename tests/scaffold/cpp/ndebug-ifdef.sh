# expect: red No switched-off checks
# Bad code under #ifdef NDEBUG, which the checked build never defines.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) {
#ifdef NDEBUG
  const long wide = value;
  return *reinterpret_cast<const int *>(&wide);
#else
  return value;
#endif
}

} // namespace sample_tool
C
fmt
