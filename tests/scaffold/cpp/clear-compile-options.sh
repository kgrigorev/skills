# expect: red Configure (CMakePresets.json
# COMPILE_OPTIONS replaced on the target, which drops most of strict.cmake.
. "$(dirname "$0")/lib/attack"
shadow_body | add_extra
cmake_append 'set_target_properties(sample_tool_lib PROPERTIES COMPILE_OPTIONS "-Werror;-Wconversion")'
fmt
