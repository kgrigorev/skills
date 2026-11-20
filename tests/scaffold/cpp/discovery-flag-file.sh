# expect: red Configure (CMakePresets.json
# expect-output: gtest_discover_tests takes the target and DISCOVERY_MODE PRE_TEST only
# Discovery reads a gtest flag file with --gtest_filter, so the failing test is never registered and the count still matches.
. "$(dirname "$0")/lib/attack"
break_banner
printf -- '--gtest_filter=Greet.*\n' >tests/gtest.flags
perl -pi -e 's|^gtest_discover_tests\(sample_tool_test DISCOVERY_MODE PRE_TEST\)$|gtest_discover_tests(sample_tool_test DISCOVERY_MODE PRE_TEST\n  DISCOVERY_EXTRA_ARGS --gtest_flagfile=\${CMAKE_SOURCE_DIR}/tests/gtest.flags)|' CMakeLists.txt
grep -q flagfile CMakeLists.txt
