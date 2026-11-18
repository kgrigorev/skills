# expect: red No switched-off checks
# A __asan_default_options function that turns error reports off.
. "$(dirname "$0")/lib/attack"
add_tests <<'C'
extern "C" const char *__asan_default_options();
extern "C" const char *__asan_default_options() { return "halt_on_error=0"; }
C
fmt
