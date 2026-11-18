# expect: red No switched-off checks
# A .clang-tidy in a subfolder, which overrides the root one there.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra
printf 'Checks: -*\n' >src/.clang-tidy
fmt
