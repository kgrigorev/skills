# expect: green
# A new library function with a rapidcheck property.
. "$(dirname "$0")/lib/attack"
cat >>src/sample_tool.hpp <<'C'

namespace sample_tool {

// The text with its characters in reverse order.
[[nodiscard]] std::string reversed(std::string_view text);

} // namespace sample_tool
C
cat >>src/sample_tool.cpp <<'C'

namespace sample_tool {

std::string reversed(std::string_view text) { return {text.rbegin(), text.rend()}; }

} // namespace sample_tool
C
add_tests <<'C'
// Reversing twice gives back the original text.
RC_GTEST_PROP(Reversed, TwiceIsTheOriginal, (const std::string &text)) {
  RC_ASSERT(sample_tool::reversed(sample_tool::reversed(text)) == text);
}

TEST(Reversed, ReversesAWord) { EXPECT_EQ(sample_tool::reversed("abc"), "cba"); }
C
fmt
