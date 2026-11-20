# expect: red Configure (CMakePresets.json
# An include directory outside the project, whose headers no gate reads.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_include_directories(sample_tool_lib PRIVATE /var/empty)'
