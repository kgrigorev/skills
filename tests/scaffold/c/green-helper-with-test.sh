# expect: green
# A small dependency-free helper in the existing library, with a test in the existing file.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Counts the bytes of `text` that equal `c`.\n[[nodiscard]] size_t sample_tool_count(const char *text, char c);\n$1/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

size_t sample_tool_count(const char *text, char c) {
    size_t count = 0;
    for (const char *p = text; *p != '\0'; p++) {
        if (*p == c) {
            count++;
        }
    }
    return count;
}
X
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void count_finds_every_match(void) {\n    TEST_ASSERT_EQUAL_size_t(3, sample_tool_count("a,b,c,", \x27,\x27));\n    TEST_ASSERT_EQUAL_size_t(0, sample_tool_count("", \x27,\x27));\n}\n\n$1    RUN_TEST(count_finds_every_match);\n/' test/sample_tool_test.c
