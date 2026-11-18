# expect: red No switched-off checks
# A NOLINT comment on a reinterpret_cast.
. "$(dirname "$0")/lib/attack"
cast_body | perl -pe 's|(reinterpret_cast.*;)$|$1 // NOLINT|' | add_extra
fmt
