# expect: red Test (sanitizers on
# A CTestCustom.cmake in the build folder with CTEST_CUSTOM_TESTS_IGNORE, which both ctest runs read.
. "$(dirname "$0")/lib/attack"
break_banner
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'file(WRITE ${CMAKE_BINARY_DIR}/CTestCustom.cmake "set(CTEST_CUSTOM_TESTS_IGNORE Banner.NamesTheProgram)\n")'
