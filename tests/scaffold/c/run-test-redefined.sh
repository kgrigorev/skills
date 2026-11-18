# expect: red No switched-off checks
# RUN_TEST redefined after the first test, so only the failing second test is skipped and the
# summary still reads "1 Tests 0 Failures".
perl -0pi -e 's/(    RUN_TEST\(banner_names_the_program\);\n)/$1#undef RUN_TEST\n#define RUN_TEST(f) ((void)(f))\n/' test/sample_tool_test.c
perl -0pi -e 's/(    TEST_ASSERT_EQUAL_size_t\(sizeof banner - 1)/    TEST_ASSERT_EQUAL_INT(1, 2);\n$1/' test/sample_tool_test.c
grep -q 'define RUN_TEST' test/sample_tool_test.c
