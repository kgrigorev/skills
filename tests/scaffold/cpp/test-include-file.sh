# expect: red Test (sanitizers on
# A TEST_INCLUDE_FILES script that sets an ENVIRONMENT property after discovery.
. "$(dirname "$0")/lib/attack"
break_property
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set_property(DIRECTORY APPEND PROPERTY TEST_INCLUDE_FILES ${CMAKE_SOURCE_DIR}/extra_tests.cmake)'
printf 'set_tests_properties(Greet.WrapsAnyName PROPERTIES ENVIRONMENT "RC_PARAMS=max_success=1")\n' >extra_tests.cmake
