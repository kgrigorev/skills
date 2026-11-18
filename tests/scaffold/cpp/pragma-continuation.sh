# expect: red No switched-off checks
# A diagnostic pragma split over two lines with a backslash.
. "$(dirname "$0")/lib/attack"
{ printf '#pragma \\\n    clang diagnostic ignored "-Wshadow-all"\n'; shadow_body; } | add_extra
fmt
