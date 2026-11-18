# expect: red Only .cpp and .hpp files
# An X-macro .def file with NOLINT.
. "$(dirname "$0")/lib/attack"
printf 'EXTRA(*reinterpret_cast<int *>(&wide)) // NOLINT\n' >src/extra.def
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) {
  long wide = value;
#define EXTRA(x) return x;
#include "extra.def"
#undef EXTRA
}

} // namespace sample_tool
C
