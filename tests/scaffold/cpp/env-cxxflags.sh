# expect: red Build (warnings are errors)
# CXXFLAGS=-w from the caller, which would silence the compiler.
. "$(dirname "$0")/lib/attack"
# env: CXXFLAGS=-w
shadow_body | add_extra
fmt
