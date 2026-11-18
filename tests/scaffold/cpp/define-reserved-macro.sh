# expect: red Configure (CMakePresets.json
# A reserved macro defined from CMake (__clang_analyzer__), so code under it is never linted.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_compile_definitions(sample_tool_lib PRIVATE __clang_analyzer__=1)'
