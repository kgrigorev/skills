# expect: red No switched-off checks
# disable_sanitizer_instrumentation on a function that overflows. UBSan would still stop it, but
# the attribute also hides ASan errors, so the search rejects it.
. "$(dirname "$0")/lib/attack"
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

[[clang::disable_sanitizer_instrumentation]] int extra(int value) { return value + 1; }

} // namespace sample_tool
C
extra_overflow_test
fmt
