# expect: red No switched-off checks
# A library file that includes <rapidcheck.h>, which would lint it as a test file.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <rapidcheck.h>

namespace sample_tool {

int extra(int value) { return value + 1; }

} // namespace sample_tool
C
fmt
