# expect: green
# A platform #if, a feature-test macro, digit separators, and literals that hold words the
# searches look for in code (abort, _Pragma, DISABLED, return;).
. "$(dirname "$0")/lib/attack"
cat >src/notes.hpp <<'C'
// Short notes about the machine the program runs on.
#pragma once

#include <string_view>

namespace sample_tool {

// The name of the operating system family.
[[nodiscard]] std::string_view platform_name();

// A sample text that names a few C++ words.
[[nodiscard]] std::string_view sample_text();

// One million, written with digit separators.
inline constexpr int one_million = 1'000'000;

} // namespace sample_tool
C
cat >src/notes.cpp <<'C'
#include "notes.hpp"

#include <string_view>

namespace sample_tool {

std::string_view platform_name() {
#ifdef __APPLE__
  return "macOS";
#elifdef __linux__
  return "Linux";
#else
  return "other";
#endif
}

std::string_view sample_text() {
  // Raw strings and character literals are text, not code: abort() _Pragma DISABLED.
  constexpr char quote = '\'';
  static_cast<void>(quote);
  return R"text(abort(); _Pragma("x") #pragma clang DISABLED_ return; "quoted")text";
}

} // namespace sample_tool
C
add_to_library src/notes.cpp
perl -pi -e 's|^#include "sample_tool.hpp"$|#include "notes.hpp"\n$&|' tests/sample_tool_test.cpp
add_tests <<'C'
TEST(Notes, NameThePlatform) { EXPECT_FALSE(sample_tool::platform_name().empty()); }

TEST(Notes, KeepTheSampleText) {
  EXPECT_TRUE(sample_tool::sample_text().starts_with("abort(); _Pragma"));
  EXPECT_EQ(sample_tool::one_million, 1000 * 1000);
  // A lambda with a bare return is fine in a library, and the property below skips with RC_PRE.
  EXPECT_EQ(std::string_view{"return;"}.size(), 7U);
}

RC_GTEST_PROP(Notes, GreetsNonEmptyNames, (const std::string &name)) {
  RC_PRE(!name.empty());
  RC_ASSERT(sample_tool::greet(name).size() > name.size());
}
C
perl -pi -e 's|^#include <string>$|$&\n#include <string_view>|' tests/sample_tool_test.cpp
fmt
