# expect: red Dependencies pinned by URL and SHA-256
# write_file, an old command still in CMake, writes a script into the build folder that include then runs.
. "$(dirname "$0")/lib/attack"
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'write_file(${CMAKE_BINARY_DIR}/late.cmake "execute_process(COMMAND true)")'
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'include(${CMAKE_BINARY_DIR}/late.cmake)'
