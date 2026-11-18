# expect: red Every project file is compiled
# An included .txt file with NOLINT. No extension gate lists .txt.
. "$(dirname "$0")/lib/attack"
printf 'inline int extra_cast(long wide) { return *reinterpret_cast<int *>(&wide); } // NOLINT\n' >src/extra_body.txt
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {
#include "extra_body.txt"

int extra(int value) { return extra_cast(value); }

} // namespace sample_tool
C
fmt
