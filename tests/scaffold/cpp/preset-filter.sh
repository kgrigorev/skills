# expect: red Test (sanitizers on
# A filter in the test preset that leaves out the failing test.
. "$(dirname "$0")/lib/attack"
break_banner
perl -0pi -e 's|"output": \{ "outputOnFailure": true \},|$&\n      "filter": { "exclude": { "name": "Banner" } },|' CMakePresets.json
grep -q '"filter"' CMakePresets.json
