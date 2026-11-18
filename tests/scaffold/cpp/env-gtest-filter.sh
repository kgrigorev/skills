# expect: red Test (sanitizers on
# GTEST_FILTER from the caller, which would skip the failing test.
. "$(dirname "$0")/lib/attack"
# env: GTEST_FILTER=Greet.*
break_banner
