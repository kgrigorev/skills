# expect: green
# A CMake file included from another included file, by a path from the project root, as CMake reads it.
. "$(dirname "$0")/lib/attack"
printf '# Options.\ninclude(cmake/options-b.cmake)\n' >cmake/options-a.cmake
printf '# More options.\nset(sample_tool_extra_option ON)\n' >cmake/options-b.cmake
cmake_append 'include(cmake/options-a.cmake)'
