# expect: red Configure (CMakePresets.json
# A folder under build/dev/_deps that is not GoogleTest or rapidcheck, marked as system headers.
. "$(dirname "$0")/lib/attack"
mkdir -p build/dev/_deps/vendor-src
printf '#pragma once\ninline int vcast(long w) { return *reinterpret_cast<int *>(&w); }\n' >build/dev/_deps/vendor-src/v.hpp
add_extra <<'C'
#include "extra.hpp"

#include <v.hpp>

namespace sample_tool {

int extra(int value) { return vcast(value); }

} // namespace sample_tool
C
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_include_directories(sample_tool_lib SYSTEM PRIVATE ${CMAKE_BINARY_DIR}/_deps/vendor-src)'
fmt
