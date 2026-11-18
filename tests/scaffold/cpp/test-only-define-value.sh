# expect: red Configure (CMakePresets.json
# The same macro gets one value in the test target and another in the program, so a header
# function is right only in the tests.
. "$(dirname "$0")/lib/attack"
cat >>src/sample_tool.hpp <<'C'

namespace sample_tool {

// Twice the value.
[[nodiscard]] inline int twice(int value) { return value * SAMPLE_TOOL_FACTOR; }

} // namespace sample_tool
C
add_tests <<'C'
TEST(Twice, DoublesTheValue) { EXPECT_EQ(sample_tool::twice(5), 10); }
C
cmake_append 'target_compile_definitions(sample_tool_test PRIVATE SAMPLE_TOOL_FACTOR=2)'
cmake_append 'target_compile_definitions(sample_tool_lib PRIVATE SAMPLE_TOOL_FACTOR=1)'
cmake_append 'target_compile_definitions(sample-tool PRIVATE SAMPLE_TOOL_FACTOR=1)'
fmt
