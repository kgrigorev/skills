# expect: green
# A test that links the C math library by name.
perl -pi -e 's{add_unity_test\(sample_tool_test test/sample_tool_test.c sample_tool\)}{add_unity_test(sample_tool_test test/sample_tool_test.c sample_tool m)}' CMakeLists.txt
grep -q 'sample_tool m)' CMakeLists.txt
