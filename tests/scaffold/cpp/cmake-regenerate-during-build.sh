# expect: red Test (sanitizers on
# A configure dependency on build/dev/configure.log, which is written after build.ninja, once made ninja run CMake again during the build, without the trace and with a filled cache. That run included a hook that rewrote the failing test. CMake regeneration is off now, so the test fails.
. "$(dirname "$0")/lib/attack"
break_banner
mkdir -p docs
cat >docs/hook.txt <<'M'
execute_process(COMMAND perl -pi -e "s/nope/sample-tool/" ${CMAKE_SOURCE_DIR}/tests/sample_tool_test.cpp)
M
# shellcheck disable=SC2016 # CMake expands it
perl -0pi -e 's|^project\(|if(DEFINED CACHE{SAMPLE_TOOL_SEEN})\n  set(CMAKE_PROJECT_INCLUDE \${CMAKE_CURRENT_SOURCE_DIR}/docs/hook.txt)\nendif()\nset(SAMPLE_TOOL_SEEN ON CACHE BOOL "")\n$&|m' CMakeLists.txt
grep -q SAMPLE_TOOL_SEEN CMakeLists.txt
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${CMAKE_BINARY_DIR}/configure.log)'
