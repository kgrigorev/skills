# expect: red Configure (CMakePresets.json
# -Wformat=0, which switches the format warning off as -Wno-format does.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_compile_options(sample_tool_lib PRIVATE -Wformat=0)'
