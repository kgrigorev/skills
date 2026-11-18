# expect: red No switched-off checks
# target_compile_options with -Wno-shadow-all.
. "$(dirname "$0")/lib/attack"
shadow_body | add_extra
cmake_append 'target_compile_options(sample_tool_lib PRIVATE -Wno-shadow-all)'
fmt
