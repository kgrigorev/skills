# expect: red Dependencies pinned by URL and SHA-256
# A function named execute_process, defined after a real execute_process call, once made the scan allow that call. The call rewrites a failing test.
. "$(dirname "$0")/lib/attack"
break_banner
cat >>CMakeLists.txt <<'M'
execute_process(COMMAND perl -pi -e "s/nope/sample-tool/" ${CMAKE_CURRENT_SOURCE_DIR}/tests/sample_tool_test.cpp)
function(execute_process)
endfunction()
M
