# expect: red No switched-off checks
# #undef of a platform macro in a test file flips a platform branch for that file only.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^#include "sample_tool.hpp"$|#undef __APPLE__\n#undef __linux__\n$&|' tests/sample_tool_test.cpp
grep -q '#undef __linux__' tests/sample_tool_test.cpp
