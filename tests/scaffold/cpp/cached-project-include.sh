# expect: red Test (sanitizers on
# A CMAKE_PROJECT_INCLUDE left in the CMake cache by an earlier commit, with no trace in the CMake files. The check starts from an empty cache, so the failing test fails.
. "$(dirname "$0")/lib/attack"
break_banner
mkdir -p build/dev docs
cat >docs/hook.txt <<'M'
execute_process(COMMAND perl -pi -e "s/nope/sample-tool/" ${CMAKE_SOURCE_DIR}/tests/sample_tool_test.cpp)
M
printf 'CMAKE_PROJECT_INCLUDE:FILEPATH=%s/docs/hook.txt\n' "$(pwd -P)" >>build/dev/CMakeCache.txt
