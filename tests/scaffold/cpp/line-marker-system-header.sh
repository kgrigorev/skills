# expect: red Build (warnings are errors)
# A GNU line marker with flag 3 marks the rest of the file as a system header, so warnings and clang-tidy skip it. -Wpedantic (-Wgnu-line-marker) rejects the marker; clang-tidy alone does not.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"
# 1 "vendor/fast.hpp" 1 3

namespace sample_tool {

int extra(int value) {
  const long wide = value;
  return *reinterpret_cast<const int *>(&wide);
}

} // namespace sample_tool
C
fmt
