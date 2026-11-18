# expect: red Test (sanitizers on
# Control: a property that fails for names of 3 or more characters.
. "$(dirname "$0")/lib/attack"
break_property
