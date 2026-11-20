# expect: red Only .cpp and .hpp files
# A source file named .cc.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra cc
