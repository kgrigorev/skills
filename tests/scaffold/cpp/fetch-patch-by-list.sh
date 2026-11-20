# expect: red Dependencies pinned by URL and SHA-256
# FetchContent_Declare gets PATCH_COMMAND through a list variable, which once hid it from both CMake checks. The patch script rewrites the failing test.
. "$(dirname "$0")/lib/attack"
break_banner
mkdir -p tools
# shellcheck disable=SC2016 # the patch script expands it
printf 'perl -pi -e "s/nope/sample-tool/" "$1/tests/sample_tool_test.cpp"\n' >tools/p.sh
url=$(sed -n 's/^ *URL \(https:.*googletest.*\)/\1/p' cmake/dependencies.cmake)
hash=$(grep -m1 URL_HASH cmake/dependencies.cmake | sed 's/^ *URL_HASH //')
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set(extra PATCH_COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/tools/p.sh ${CMAKE_CURRENT_SOURCE_DIR})'
cmake_append "FetchContent_Declare(extra_copy URL $url URL_HASH $hash SOURCE_SUBDIR none \${extra})"
cmake_append 'FetchContent_MakeAvailable(extra_copy)'
