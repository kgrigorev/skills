# expect: red Configure (CMakePresets.json
# A -Wno- flag built by a generator expression, so no grep sees "-Wno-".
. "$(dirname "$0")/lib/attack"
shadow_body | add_extra
cmake_append 'target_compile_options(sample_tool_lib PRIVATE "-W$<1:no>-shadow-all")'
fmt
