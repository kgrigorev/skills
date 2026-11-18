# expect: red Test (sanitizers on
# Control: a test reads past a std::array. The hardened standard library stops it.
. "$(dirname "$0")/lib/attack"
out_of_bounds_test
fmt
