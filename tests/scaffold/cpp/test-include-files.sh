# expect: red Test (sanitizers on
# A TEST_INCLUDE_FILES script that gives the property one tiny case in the real ctest run only (GTEST_OUTPUT is set), not in --show-only.
. "$(dirname "$0")/lib/attack"
cat >cmake/ctest-extra.cmake <<'M'
if(DEFINED ENV{GTEST_OUTPUT})
  set_tests_properties(Greet.WrapsAnyName PROPERTIES ENVIRONMENT "RC_PARAMS=seed=1 max_success=1 max_size=0")
endif()
M
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set_property(DIRECTORY APPEND PROPERTY TEST_INCLUDE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/cmake/ctest-extra.cmake)'
break_property
fmt
