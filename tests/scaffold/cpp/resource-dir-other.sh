# expect: red Configure (CMakePresets.json
# A second -resource-dir, whose share/ubsan_ignorelist.txt could switch UBSan off for every function.
. "$(dirname "$0")/lib/attack"
mkdir -p res/share
printf '[undefined]\nfun:*\n' >res/share/ubsan_ignorelist.txt
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(sample_tool_lib PRIVATE -resource-dir=${CMAKE_SOURCE_DIR}/res)'
