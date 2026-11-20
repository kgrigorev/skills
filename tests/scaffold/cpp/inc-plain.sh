# expect: red Only .cpp and .hpp files
# An included .inc file with a reinterpret_cast.
. "$(dirname "$0")/lib/attack"
printf 'inline int extra_cast(long wide) { return *reinterpret_cast<int *>(&wide); }\n' >src/extra.inc
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {
#include "extra.inc"

int extra(int value) { return extra_cast(value); }

} // namespace sample_tool
C
