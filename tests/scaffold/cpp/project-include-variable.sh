# expect: red Configure (CMakePresets.json
# CMAKE_PROJECT_INCLUDE makes project() run a file that the scan never reads, which rewrites a failing test.
. "$(dirname "$0")/lib/attack"
break_banner
mkdir -p docs
cat >docs/hook.txt <<'M'
execute_process(COMMAND perl -pi -e "s/nope/sample-tool/" ${CMAKE_SOURCE_DIR}/tests/sample_tool_test.cpp)
M
# shellcheck disable=SC2016 # CMake expands it
perl -pi -e 's|^project\(|set(CMAKE_PROJECT_INCLUDE \${CMAKE_CURRENT_SOURCE_DIR}/docs/hook.txt)\n$&|' CMakeLists.txt
grep -q CMAKE_PROJECT_INCLUDE CMakeLists.txt
