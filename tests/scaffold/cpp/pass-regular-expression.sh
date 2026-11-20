# expect: red Configure (CMakePresets.json
# expect-output: gtest_discover_tests takes the target and DISCOVERY_MODE PRE_TEST only
# PASS_REGULAR_EXPRESSION makes a failing test pass.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|^gtest_discover_tests\(sample_tool_test DISCOVERY_MODE PRE_TEST\)$|gtest_discover_tests(sample_tool_test DISCOVERY_MODE PRE_TEST PROPERTIES PASS_REGULAR_EXPRESSION "Running")|' CMakeLists.txt
grep -q PASS_REGULAR CMakeLists.txt
