# expect: red Configure (CMakePresets.json
# An executable built only from an object library, in a folder whose CMAKE_CXX_FLAGS reach its link step but no compile command.
. "$(dirname "$0")/lib/attack"
perl -0pi -e 's/add_executable\(sample_tool_test .*//s' CMakeLists.txt
cat >>CMakeLists.txt <<'M'
add_library(sample_tool_test_objects OBJECT tests/sample_tool_test.cpp)
target_link_libraries(sample_tool_test_objects PRIVATE sample_tool_lib GTest::gtest_main rapidcheck_gtest)
add_subdirectory(runner)
M
mkdir -p runner
cat >runner/CMakeLists.txt <<'M'
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -rdynamic")
add_executable(sample_tool_test $<TARGET_OBJECTS:sample_tool_test_objects>)
target_link_libraries(sample_tool_test PRIVATE sample_tool_lib GTest::gtest_main rapidcheck_gtest)
gtest_discover_tests(sample_tool_test DISCOVERY_MODE PRE_TEST)
M
