# expect: red Every project file is compiled
# A clean .cpp that no target compiles, so its tests never run.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) { return value; }

} // namespace sample_tool
C
perl -pi -e 's| src/extra\.cpp||' CMakeLists.txt
fmt
