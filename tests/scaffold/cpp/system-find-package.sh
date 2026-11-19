# expect: red Configure (CMakePresets.json
# A library from the machine with find_package.
# On Linux the conda toolchain reads only its own sysroot, so find_package finds no library for it.
. "$(dirname "$0")/lib/attack"
cmake_append 'find_package(ZLIB REQUIRED)'
cmake_append 'target_link_libraries(sample_tool_lib PUBLIC ZLIB::ZLIB)'
