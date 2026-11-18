# expect: red No switched-off checks
# Bad code under #ifndef __clang_analyzer__, which clang-tidy defines.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) {
  const long wide = value;
#ifndef __clang_analyzer__
  return *reinterpret_cast<const int *>(&wide);
#else
  return static_cast<int>(wide);
#endif
}

} // namespace sample_tool
C
fmt
