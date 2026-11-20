# expect: green
# The tests in their own folder with their own CMakeLists.txt, an ordinary layout.
. "$(dirname "$0")/lib/attack"
perl -0pi -e 's/add_executable\(sample_tool_test .*//s' CMakeLists.txt
printf 'add_subdirectory(tests)\n' >>CMakeLists.txt
cat >tests/CMakeLists.txt <<'M'
add_executable(sample_tool_test sample_tool_test.cpp)
target_link_libraries(sample_tool_test PRIVATE sample_tool_lib GTest::gtest_main rapidcheck_gtest)
gtest_discover_tests(sample_tool_test DISCOVERY_MODE PRE_TEST)
M
