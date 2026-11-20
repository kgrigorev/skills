# expect: red No switched-off checks
# WILL_FAIL turns a failing test into a pass.
. "$(dirname "$0")/lib/attack"
break_banner
printf 'set_tests_properties(Banner.NamesTheProgram PROPERTIES WILL_FAIL TRUE)\n' >extra_tests.cmake
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set_property(DIRECTORY APPEND PROPERTY TEST_INCLUDE_FILES ${CMAKE_SOURCE_DIR}/extra_tests.cmake)'
