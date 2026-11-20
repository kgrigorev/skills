# expect: red Configure (CMakePresets.json
# NDEBUG defined for the library.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_compile_definitions(sample_tool_lib PRIVATE NDEBUG)'
