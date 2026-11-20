# expect: green
# A C99 inline function in the library header, with its extern definition in the library.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ The smaller of `a` and `b`.\ninline size_t sample_tool_min(size_t a, size_t b) { return a < b ? a : b; }\n$1/' include/sample_tool.h
printf '\nextern inline size_t sample_tool_min(size_t a, size_t b);\n' >>src/sample_tool.c
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void min_picks_the_smaller(void) { TEST_ASSERT_EQUAL_size_t(1, sample_tool_min(1, 2)); }\n\n$1    RUN_TEST(min_picks_the_smaller);\n/' test/sample_tool_test.c
scripts/format
