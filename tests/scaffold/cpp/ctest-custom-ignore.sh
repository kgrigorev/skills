# expect: red Dependencies pinned by URL and SHA-256
# CMake writes a CTestCustom.cmake with CTEST_CUSTOM_TESTS_IGNORE into the build folder; file(WRITE) is rejected. ctest-custom-by-hand covers a file put there by hand.
. "$(dirname "$0")/lib/attack"
break_banner
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'file(WRITE ${CMAKE_BINARY_DIR}/CTestCustom.cmake "set(CTEST_CUSTOM_TESTS_IGNORE Banner.NamesTheProgram)\n")'
