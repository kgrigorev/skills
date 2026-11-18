# expect: red Lint (clang-tidy
# The library calls std::exit on bad input, ending the caller's program.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

namespace sample_tool {

int extra(int value) {
  if (value < 0) {
    std::exit(EXIT_FAILURE);
  }
  return value;
}

} // namespace sample_tool
C
fmt
