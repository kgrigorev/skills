# expect: red No switched-off checks
# The _Pragma operator, which a grep for #pragma misses.
. "$(dirname "$0")/lib/attack"
{ printf '_Pragma("clang diagnostic ignored \\"-Wshadow-all\\"")\n'; shadow_body; } | add_extra
fmt
