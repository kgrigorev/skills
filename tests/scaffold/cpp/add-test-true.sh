# expect: red Test (sanitizers on
# A custom add_test that runs `true`.
. "$(dirname "$0")/lib/attack"
cmake_append 'add_test(NAME Always COMMAND true)'
