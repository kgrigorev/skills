# expect: red Lint (clang-tidy
# Control: an empty catch (...) swallows every exception.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <string>

namespace sample_tool {

int extra(int value) {
  try {
    return std::stoi(std::to_string(value));
  } catch (...) {
  }
  return 0;
}

} // namespace sample_tool
C
fmt
