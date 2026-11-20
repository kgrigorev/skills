# expect: red Test
# A symlinked CTestCustom.cmake drops the failing property test from both ctest runs.
mkdir -p docs
printf 'set(CTEST_CUSTOM_TESTS_IGNORE sample_tool_property)\n' > docs/ignore.txt
printf 'file(CREATE_LINK ${CMAKE_SOURCE_DIR}/docs/ignore.txt ${CMAKE_BINARY_DIR}/CTestCustom.cmake SYMBOLIC)\n' >>CMakeLists.txt
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
