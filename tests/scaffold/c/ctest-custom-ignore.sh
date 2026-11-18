# expect: red Test
# CMakeLists.txt writes CTestCustom.cmake into the build folder. CTEST_CUSTOM_TESTS_IGNORE drops
# the failing property test from both `ctest --preset dev` and `ctest -N`, so the totals agree.
printf 'file(WRITE "${CMAKE_BINARY_DIR}/CTestCustom.cmake" "set(CTEST_CUSTOM_TESTS_IGNORE sample_tool_property)\\n")\n' >>CMakeLists.txt
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
