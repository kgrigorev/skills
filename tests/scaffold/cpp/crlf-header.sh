# expect: red No switched-off checks
# A new header with CR LF line ends. It is a new file, so the test runner's reset deletes it even where git turns CR LF into LF on add.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) { return value + 1; }

} // namespace sample_tool
C
perl -pi -e 's/\n/\r\n/' src/extra.hpp
