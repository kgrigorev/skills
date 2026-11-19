# expect: red Test (sanitizers on
# TESTBRIDGE_TEST_ONLY from the caller's shell, which GoogleTest reads as its default filter.
# env: TESTBRIDGE_TEST_ONLY=Greet.*
. "$(dirname "$0")/lib/attack"
break_banner
