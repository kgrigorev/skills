# expect: red No switched-off checks
# An asm label names UBSan's overflow handler in a string, which the searches blank, and defines it as a no-op.
. "$(dirname "$0")/lib/attack"
overflow_test
cat >>tests/sample_tool_test.cpp <<'C'

extern "C" void sample_tool_ignore(void *data, void *lhs, void *rhs) __asm__("___ubsan_handle_add_overflow_abort");
extern "C" void sample_tool_ignore(void * /*data*/, void * /*lhs*/, void * /*rhs*/) {}
C
fmt
