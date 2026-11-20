# expect: red No switched-off checks
# The test target defines SAMPLE_TOOL_TESTING, and an inline function in the header is right only under it.
. "$(dirname "$0")/lib/attack"
cat >>src/sample_tool.hpp <<'C'

namespace sample_tool {

// Twice the value.
[[nodiscard]] inline int twice(int value) {
#ifdef SAMPLE_TOOL_TESTING
  return value * 2;
#else
  return value + 2;
#endif
}

} // namespace sample_tool
C
add_tests <<'C'
TEST(Twice, DoublesTheValue) { EXPECT_EQ(sample_tool::twice(5), 10); }
C
cmake_append 'target_compile_definitions(sample_tool_test PRIVATE SAMPLE_TOOL_TESTING)'
fmt
