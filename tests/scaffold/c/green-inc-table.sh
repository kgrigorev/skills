# expect: green
# A table in a .inc file that a source includes, and a compile definition for a limit.
cat >src/weekdays.inc <<'X'
// One entry per weekday, Monday first.
"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
X
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Returns the three-letter name of weekday `day` (0 is Monday), or nullptr.\n[[nodiscard]] const char *sample_tool_weekday(unsigned day);\n$1/' include/sample_tool.h
cat >>src/sample_tool.c <<'X'

static const char *const weekdays[] = {
#include "weekdays.inc"
};
static_assert(sizeof weekdays / sizeof weekdays[0] == SAMPLE_TOOL_DAYS);

const char *sample_tool_weekday(unsigned day) {
    return day < SAMPLE_TOOL_DAYS ? weekdays[day] : nullptr;
}
X
printf 'target_compile_definitions(sample_tool PRIVATE SAMPLE_TOOL_DAYS=7)\n' >>CMakeLists.txt
perl -0pi -e 's/(int main\(void\) \{\n    UNITY_BEGIN\(\);\n)/static void weekday_names(void) {\n    TEST_ASSERT_EQUAL_STRING("Sun", sample_tool_weekday(6));\n    TEST_ASSERT_NULL(sample_tool_weekday(7));\n}\n\n$1    RUN_TEST(weekday_names);\n/' test/sample_tool_test.c
