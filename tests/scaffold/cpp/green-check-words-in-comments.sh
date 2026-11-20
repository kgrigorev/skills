# expect: green
# Comments that name NDEBUG and the sanitizer macros while explaining the code.
. "$(dirname "$0")/lib/attack"
cat >>src/sample_tool.hpp <<'C'

namespace sample_tool {

// The character at a position, or '?' past the end.
// assert() is compiled out when NDEBUG is defined, so this checks the position itself.
[[nodiscard]] char char_at(std::string_view text, std::size_t position);

} // namespace sample_tool
C
perl -pi -e 's|^#include <string>$|#include <cstddef>\n$&|' src/sample_tool.hpp
cat >>src/sample_tool.cpp <<'C'

namespace sample_tool {

char char_at(std::string_view text, std::size_t position) {
  // Not text[position]: the test build (see __SANITIZE_ADDRESS__ in GCC) stops on a bad one.
  return position < text.size() ? text.at(position) : '?';
}

} // namespace sample_tool
C
perl -pi -e 's|^#include <format>$|#include <cstddef>\n$&|' src/sample_tool.cpp
add_tests <<'C'
TEST(CharAt, IsAQuestionMarkPastTheEnd) {
  EXPECT_EQ(sample_tool::char_at("ab", 1), 'b');
  EXPECT_EQ(sample_tool::char_at("ab", 2), '?');
}
C
fmt
