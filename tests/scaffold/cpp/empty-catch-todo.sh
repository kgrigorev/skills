# expect: red Lint (clang-tidy
# An empty catch (...) with a @TODO comment, which bugprone-empty-catch ignores by default.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <string>

namespace sample_tool {

int extra(int value) {
  try {
    return std::stoi(std::to_string(value));
  } catch (...) {
    // @TODO handle it
  }
  return 0;
}

} // namespace sample_tool
C
fmt
