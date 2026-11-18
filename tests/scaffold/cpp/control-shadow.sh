# expect: red Build (warnings are errors)
# Control: a shadowed name. The compiler rejects it.
. "$(dirname "$0")/lib/attack"
shadow_body | add_extra
fmt
