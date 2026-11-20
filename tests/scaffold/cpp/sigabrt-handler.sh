# expect: red No switched-off checks
# A SIGABRT handler that exits 0, so the hardened standard library's stop on an out-of-bounds read looks like a pass.
. "$(dirname "$0")/lib/attack"
out_of_bounds_test
perl -pi -e 's|^#include <string>$|#include <csignal>\n#include <cstdlib>\n$&|' tests/sample_tool_test.cpp
cat >>tests/sample_tool_test.cpp <<'C'

extern "C" void sample_tool_on_abort(int signal_number);
extern "C" void sample_tool_on_abort(int signal_number) {
  static_cast<void>(signal_number);
  std::_Exit(EXIT_SUCCESS);
}

namespace {
// Installs the handler before any test runs.
bool install_abort_handler() noexcept { return std::signal(SIGABRT, sample_tool_on_abort) != SIG_ERR; }

const bool abort_handler = install_abort_handler();
} // namespace
C
fmt
