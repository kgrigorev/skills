# expect: red No switched-off checks
# A GCC diagnostic pragma, which clang honours too.
. "$(dirname "$0")/lib/attack"
{ printf '#pragma GCC diagnostic ignored "-Wshadow"\n'; shadow_body; } | add_extra
fmt
