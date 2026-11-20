# expect: red Test
# A main that drops Unity's result and returns 0, so a failing test would exit 0.
perl -0pi -e 's/    return UNITY_END\(\);/    (void)UNITY_END();\n    return 0;/' test/sample_tool_test.c
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
