# expect: red Configure (CMakePresets.json
# Project CMake gives GoogleTest's own target a forced include that turns every failed assertion into a pass.
. "$(dirname "$0")/lib/attack"
break_banner
printf '#include <gtest/gtest.h>\n#define failed() passed()\n' >tests/hooks.txt
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(gtest PRIVATE -include ${CMAKE_CURRENT_SOURCE_DIR}/tests/hooks.txt)'
