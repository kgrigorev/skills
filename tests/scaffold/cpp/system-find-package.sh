# expect: red Every project file is compiled
# A library from the machine with find_package.
. "$(dirname "$0")/lib/attack"
cmake_append 'find_package(ZLIB REQUIRED)'
cmake_append 'target_link_libraries(sample_tool_lib PUBLIC ZLIB::ZLIB)'
