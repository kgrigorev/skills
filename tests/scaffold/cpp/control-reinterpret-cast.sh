# expect: red Lint (clang-tidy
# Control: a reinterpret_cast. clang-tidy rejects it.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra
fmt
