# expect: red No switched-off checks
# A NOLINTNEXTLINE comment above a reinterpret_cast.
. "$(dirname "$0")/lib/attack"
cast_body | perl -pe 's|^(  return \*reinterpret_cast)|  // NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)\n$1|' | add_extra
fmt
