# expect: red Configure (CMakePresets.json
# A file forced into every compile with -include.
. "$(dirname "$0")/lib/attack"
printf '// Forced.\n#pragma once\n' >src/forced.hpp
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(sample_tool_lib PRIVATE -include "${CMAKE_SOURCE_DIR}/src/forced.hpp")'
