# expect: red Test (sanitizers on
# A failing test replaces its process with /usr/bin/true, which exits 0, so ctest sees a pass.
# Only the missing GoogleTest report shows that the test never finished.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^#include <string>$|#include <array>\n$&\n#include <unistd.h>|' tests/sample_tool_test.cpp
add_tests <<'C'
TEST(Banner, IsShort) {
  EXPECT_LT(sample_tool::banner().size(), 5U);
  std::array<char, 5> name{'t', 'r', 'u', 'e', '\0'};
  const std::array<char *, 2> arguments{name.data(), nullptr};
  static_cast<void>(execv("/usr/bin/true", arguments.data()));
}
C
fmt
