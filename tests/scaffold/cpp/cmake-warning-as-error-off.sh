# expect: red No switched-off checks
# COMPILE_WARNING_AS_ERROR switched off on the target.
. "$(dirname "$0")/lib/attack"
cmake_append 'set_target_properties(sample_tool_lib PROPERTIES COMPILE_WARNING_AS_ERROR OFF)'
