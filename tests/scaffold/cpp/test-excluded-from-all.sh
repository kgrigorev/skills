# expect: red Configure (CMakePresets.json
# A test executable left out of the default build, so ctest runs an old binary of a failing test.
. "$(dirname "$0")/lib/attack"
break_banner
cmake_append 'set_target_properties(sample_tool_test PROPERTIES EXCLUDE_FROM_ALL TRUE)'
