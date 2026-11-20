# expect: red Dependencies pinned by URL and SHA-256
# add_subdirectory with a binary folder under build/dev/_deps (here through a ; split), which the CTestTestfile check once skipped.
. "$(dirname "$0")/lib/attack"
mkdir -p extra
# shellcheck disable=SC2016 # CMake expands it
printf 'set_property(DIRECTORY APPEND PROPERTY TEST_INCLUDE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/late.txt)\n' >extra/CMakeLists.txt
printf 'if(DEFINED ENV{GTEST_OUTPUT})\nendif()\n' >extra/late.txt
cmake_append 'add_subdirectory(extra;_deps/project-tests)'
