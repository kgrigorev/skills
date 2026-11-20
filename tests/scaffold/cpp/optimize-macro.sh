# expect: red No switched-off checks
# A reinterpret_cast under #ifdef __OPTIMIZE__, which only a release build defines, so no gate compiles it.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) {
#ifdef __OPTIMIZE__
  const long wide = value;
  return *reinterpret_cast<const int *>(&wide);
#else
  return value;
#endif
}

} // namespace sample_tool
C
fmt
