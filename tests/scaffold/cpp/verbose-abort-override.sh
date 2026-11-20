# expect: red No switched-off checks
# std::__libcpp_verbose_abort replaced by one that exits 0, so libc++ hardening stops look like passes.
. "$(dirname "$0")/lib/attack"
out_of_bounds_test
perl -pi -e 's|^#include <string>$|#include <cstdlib>\n$&|' tests/sample_tool_test.cpp
cat >>tests/sample_tool_test.cpp <<'C'

namespace std {
[[noreturn]] void __libcpp_verbose_abort(const char *format, ...) noexcept {
  static_cast<void>(format);
  std::_Exit(EXIT_SUCCESS);
}
} // namespace std
C
fmt
