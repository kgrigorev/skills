# expect: red Dependencies pinned by URL and SHA-256
# A header that configure_file writes into the build folder from a .hpp.in, which no gate reads. It switches UBSan off for extra(), which overflows.
. "$(dirname "$0")/lib/attack"
printf '#pragma once\n#define SAMPLE_TOOL_FAST __attribute__((no_sanitize("undefined")))\n' >src/attrs.hpp.in
add_extra <<'C'
#include "extra.hpp"

#include "attrs.hpp"

namespace sample_tool {

SAMPLE_TOOL_FAST int extra(int value) { return value + 1; }

} // namespace sample_tool
C
cmake_append 'configure_file(src/attrs.hpp.in ${CMAKE_BINARY_DIR}/gen/attrs.hpp COPYONLY)'
cmake_append 'target_include_directories(sample_tool_lib PUBLIC ${CMAKE_BINARY_DIR}/gen)'
extra_overflow_test
fmt
