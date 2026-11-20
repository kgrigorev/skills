# expect: red Configure (CMakePresets.json
# expect-output: gtest_discover_tests takes the target and DISCOVERY_MODE PRE_TEST only
# A gtest_discover_tests argument that closes CMake's [==[ quoting injects code into the discovery script, which ctest runs. It adds a hook that weakens the property in the real run only.
. "$(dirname "$0")/lib/attack"
break_property
mkdir -p docs
cat >docs/hook.txt <<'M'
if(DEFINED ENV{GTEST_OUTPUT})
  set_tests_properties(Greet.WrapsAnyName PROPERTIES ENVIRONMENT "RC_PARAMS=seed=1 max_success=1 max_size=0")
endif()
M
cat >>CMakeLists.txt <<'M'
gtest_discover_tests(sample_tool_test DISCOVERY_MODE PRE_TEST XML_OUTPUT_DIR "]==] TEST_JSON_OUTPUT_DIR [==[${CMAKE_CURRENT_BINARY_DIR}]==])\nstring(REPLACE _discovery.cmake _tests.cmake t \${CMAKE_CURRENT_LIST_FILE})\nfile(APPEND \${t} \"include(\${CMAKE_CURRENT_LIST_DIR}/../../docs/hook.txt)\\n\")\nset(ignored [==[")
M
perl -0pi -e 's|gtest_discover_tests\(sample_tool_test DISCOVERY_MODE PRE_TEST\)\n||' CMakeLists.txt
