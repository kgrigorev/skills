# expect: red Configure (CMakePresets.json
# A linker launcher, which runs a program around every link.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^add_library\(sample_tool_lib|set(CMAKE_CXX_LINKER_LAUNCHER /usr/bin/env)\n$&|' CMakeLists.txt
grep -q LINKER_LAUNCHER CMakeLists.txt
