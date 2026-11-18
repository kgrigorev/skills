# expect: red No switched-off checks
# The [[clang::suppress]] attribute, which hides clang-tidy findings in a block.
. "$(dirname "$0")/lib/attack"
cast_body | perl -pe 's|^  return \*reinterpret_cast(.*)$|  [[clang::suppress]] { return *reinterpret_cast$1 }|' | add_extra
fmt
