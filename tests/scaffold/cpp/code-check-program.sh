# expect: red Configure (CMakePresets.json
# CMAKE_CXX_INCLUDE_WHAT_YOU_USE runs any program before each compile, which could change the sources.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^add_library\(sample_tool_lib|set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE /usr/bin/true)\n$&|' CMakeLists.txt
grep -q INCLUDE_WHAT_YOU_USE CMakeLists.txt
