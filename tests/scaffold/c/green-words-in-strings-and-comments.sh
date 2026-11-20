# expect: green
# Words the suppression searches look for, used plainly: a variable named `unused`, the word
# "unused" in strings and comments, a sanitizer-like function name, and comments that talk about
# tests.
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Returns how many bytes of a `capacity`-byte buffer the banner leaves unused.\n[[nodiscard]] size_t sample_tool_unused_bytes(size_t capacity);\n\n\/\/\/ Replaces every byte of `text` that is not printable ASCII with \x27?\x27.\n void sample_tool_name_sanitizer(char *text);\n$1/' include/sample_tool.h
perl -pi -e 's/^ void sample_tool_name_sanitizer/void sample_tool_name_sanitizer/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

// The unused part of the buffer is left as it was.
size_t sample_tool_unused_bytes(size_t capacity) {
    const size_t used = sizeof banner;
    const size_t unused = capacity > used ? capacity - used : 0;
    return unused;
}

// In C, && gives an int, so the result is compared, as .clang-tidy asks.
static bool printable(char c) { return (c >= ' ' && c <= '~') != 0; }

void sample_tool_name_sanitizer(char *text) {
    for (char *p = text; *p != '\0'; p++) {
        if (!printable(*p)) {
            *p = '?';
        }
    }
}
X
# The banner holds the synopsis the project was rendered with, so read it from the source.
BANNER=$(sed -n 's/^static const char banner\[\] = "\(.*\)";$/\1/p' src/sample_tool.c)
[ -n "$BANNER" ]
export BANNER
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/\/\/ Test that the unused byte count is exact, and that a test never ignores a result.\nstatic void unused_bytes_are_counted(void) {\n    const size_t unused = sample_tool_unused_bytes(200);\n    TEST_ASSERT_EQUAL_size_t(200 - sizeof "$ENV{BANNER}",\n                             unused);\n    TEST_ASSERT_EQUAL_size_t(0, sample_tool_unused_bytes(3));\n    TEST_ASSERT_EQUAL_STRING("unused", "unused");\n}\n\nstatic void sanitizer_replaces_control_bytes(void) {\n    char name[] = "a\\tb";\n    sample_tool_name_sanitizer(name);\n    TEST_ASSERT_EQUAL_STRING("a?b", name);\n}\n\n$1    RUN_TEST(unused_bytes_are_counted);\n    RUN_TEST(sanitizer_replaces_control_bytes);\n/' test/sample_tool_test.c
