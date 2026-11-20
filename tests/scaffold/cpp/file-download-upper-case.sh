# expect: red Dependencies pinned by URL and SHA-256
# FILE(DOWNLOAD) in upper case.
. "$(dirname "$0")/lib/attack"
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'FILE(DOWNLOAD https://example.invalid/x.hpp ${CMAKE_BINARY_DIR}/x.hpp STATUS download_status)'
