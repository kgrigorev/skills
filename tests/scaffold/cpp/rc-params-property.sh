# expect: red Configure (CMakePresets.json
# expect-output: gtest_discover_tests takes the target and DISCOVERY_MODE PRE_TEST only
# An ENVIRONMENT test property that runs each property once.
. "$(dirname "$0")/lib/attack"
break_property
perl -pi -e 's|^gtest_discover_tests\(sample_tool_test DISCOVERY_MODE PRE_TEST\)$|gtest_discover_tests(sample_tool_test DISCOVERY_MODE PRE_TEST PROPERTIES ENVIRONMENT "RC_PARAMS=max_success=1")|' CMakeLists.txt
grep -q RC_PARAMS CMakeLists.txt
