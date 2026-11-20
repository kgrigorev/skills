# expect: red Test (sanitizers on
# Control: a test overflows a signed int. UBSan stops it.
. "$(dirname "$0")/lib/attack"
overflow_test
fmt
