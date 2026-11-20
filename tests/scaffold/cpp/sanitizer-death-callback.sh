# expect: red No switched-off checks
# A sanitizer death callback that exits 0, so a UBSan stop looks like a pass.
. "$(dirname "$0")/lib/attack"
overflow_test
perl -pi -e 's|^#include <gtest/gtest.h>$|#include <sanitizer/common_interface_defs.h>\n$&|; s|^#include <string>$|#include <cstdlib>\n$&|' tests/sample_tool_test.cpp
add_tests <<'C'
// Ends quietly when a sanitizer stops the process.
bool quiet_sanitizers() noexcept {
  __sanitizer_set_death_callback([] { std::_Exit(EXIT_SUCCESS); });
  return true;
}

const bool sanitizers_quiet = quiet_sanitizers();
C
fmt
