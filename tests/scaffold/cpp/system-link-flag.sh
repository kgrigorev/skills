# expect: red Every project file is compiled
# A library from the machine linked by name (-lz).
. "$(dirname "$0")/lib/attack"
cmake_append 'target_link_libraries(sample_tool_lib PUBLIC z)'
