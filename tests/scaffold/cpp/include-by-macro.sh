# expect: red No switched-off checks
# GoogleTest included through a macro in a file outside tests/, so the test rules do not apply to it.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#define DEBUG_LIBRARY "gtest/gtest.h"
#include DEBUG_LIBRARY

namespace sample_tool {

int extra(int value) { return value; }

} // namespace sample_tool
C
fmt
