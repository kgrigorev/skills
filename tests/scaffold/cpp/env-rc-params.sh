# expect: red Test (sanitizers on
# RC_PARAMS from the caller, which would run each property once.
. "$(dirname "$0")/lib/attack"
# env: RC_PARAMS=max_success=1
break_property
