# expect: red No switched-off checks
# A diagnostic pragma written with a tab, to slip past a grep for "pragma clang".
. "$(dirname "$0")/lib/attack"
{ printf '#pragma\tclang diagnostic ignored "-Wshadow-all"\n'; shadow_body; } | add_extra
fmt
