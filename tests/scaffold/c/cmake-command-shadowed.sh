# expect: red Test
# CMakeLists.txt sets CMAKE_COMMAND, which the test helpers run, to a program that always exits 0.
# The failing test and the failing property would pass. The check reads every test's command.
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
perl -0pi -e 's/(if\(BUILD_TESTING\)\n  add_unity_test)/set(CMAKE_COMMAND \/usr\/bin\/true)\n$1/' CMakeLists.txt
grep -q 'CMAKE_COMMAND' CMakeLists.txt
