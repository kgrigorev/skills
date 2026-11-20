# expect: green
# file(GLOB ... CONFIGURE_DEPENDS), which once added a rule the check did not know.
. "$(dirname "$0")/lib/attack"
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'file(GLOB sample_tool_headers CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp)'
