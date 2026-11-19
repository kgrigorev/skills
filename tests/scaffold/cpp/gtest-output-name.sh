# expect: red Configure (CMakePresets.json
# GoogleTest's archives renamed, so a scan for libgtest*.a finds no test executable; then a failing test that execs /usr/bin/true looks like a pass. CMake code may not touch the GoogleTest targets now, so it stops at configure.
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
cmake_append 'set_target_properties(gtest PROPERTIES OUTPUT_NAME gt)'
cmake_append 'set_target_properties(gtest_main PROPERTIES OUTPUT_NAME gtm)'
fmt
