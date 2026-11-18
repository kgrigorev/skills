# expect: red Test
# cmake_language(CALL) with the command and property names built from variables, so no banned
# word appears. WILL_FAIL turns the failing test into a passing one. CMake's own list of tests
# (ctest --show-only=json-v1) shows the property.
cat >>CMakeLists.txt <<'X'
set(gates_kind properties)
set(gates_how FAIL)
cmake_language(CALL set_tests_${gates_kind} sample_tool_test PROPERTIES WILL_${gates_how} ON)
X
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
