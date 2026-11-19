# expect: green
# Ordinary CMake and preprocessor code: an option, a read-only file hash, install, a POSIX header check.
. "$(dirname "$0")/lib/attack"
cat >>CMakeLists.txt <<'M'
option(SAMPLE_TOOL_INSTALL "Install the program" ON)
file(SHA256 ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt lists_hash)
if(SAMPLE_TOOL_INSTALL)
  install(TARGETS sample-tool)
endif()
M
add_extra <<'C'
#include "extra.hpp"

#if __has_include(<unistd.h>) && __cplusplus
#include <unistd.h>
#endif

namespace sample_tool {

int extra(int value) {
#if __has_include(<unistd.h>) && __cplusplus
  if (::isatty(STDIN_FILENO) < 0) {
    return value;
  }
#endif
  return value + 1;
}

} // namespace sample_tool
C
include_extra_in_tests
add_tests <<'C'
TEST(Extra, Adds) { EXPECT_EQ(sample_tool::extra(1), 2); }
C
fmt
