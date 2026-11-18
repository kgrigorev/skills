# expect: red Test (sanitizers on
# disable_sanitizer_instrumentation on a function that overflows. UBSan still stops it.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

[[clang::disable_sanitizer_instrumentation]] int extra(int value) { return value + 1; }

} // namespace sample_tool
C
extra_overflow_test
fmt
