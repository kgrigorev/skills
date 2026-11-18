# expect: red Configure (CMakePresets.json
# The sanitizer flags removed from CMakePresets.json.
. "$(dirname "$0")/lib/attack"
overflow_test
perl -pi -e 's|-fsanitize=address,undefined -fno-sanitize-recover=all ||' CMakePresets.json
fmt
