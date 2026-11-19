# expect: red No switched-off checks
# A comment between std:: and _Exit, which the search reads as spaces.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

#include <cstdlib>

namespace sample_tool {

int extra(int value) {
  if (value < 0) {
    std::/**/ _Exit(1);
  }
  return value;
}

} // namespace sample_tool
C
fmt
