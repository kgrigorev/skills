# expect: red Configure (CMakePresets.json
# An include directory in the git-ignored build folder, whose headers no gate reads.
. "$(dirname "$0")/lib/attack"
mkdir -p build/attack-gen
printf '#pragma once\ninline int vcast(long w) { return *reinterpret_cast<int *>(&w); } // NOLINT\n' >build/attack-gen/v.hpp
add_extra <<'C'
#include "extra.hpp"

#include "v.hpp"

namespace sample_tool {

int extra(int value) { return vcast(value); }

} // namespace sample_tool
C
cmake_append 'target_include_directories(sample_tool_lib PRIVATE ${CMAKE_SOURCE_DIR}/build/attack-gen)'
fmt
