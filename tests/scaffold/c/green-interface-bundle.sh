# expect: green
# The test links an INTERFACE library that bundles the real library.
perl -0pi -e 's/(\nif\(BUILD_TESTING\)\n  add_unity_test)/\nadd_library(sample_tool_all INTERFACE)\ntarget_link_libraries(sample_tool_all INTERFACE sample_tool)\n$1/' CMakeLists.txt
perl -pi -e 's{add_unity_test\(sample_tool_test test/sample_tool_test.c sample_tool\)}{add_unity_test(sample_tool_test test/sample_tool_test.c sample_tool_all)}' CMakeLists.txt
grep -q 'sample_tool_all)' CMakeLists.txt
