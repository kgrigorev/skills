# expect: red Dependencies pinned by URL and SHA-256
# file(DOWNLOAD) of a header at configure time.
. "$(dirname "$0")/lib/attack"
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'file(DOWNLOAD https://example.invalid/x.hpp ${CMAKE_BINARY_DIR}/x.hpp)'
