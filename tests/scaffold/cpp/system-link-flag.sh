# expect: red Every project file is compiled
# expect-Linux: red Build (warnings are errors)
# A library from the machine linked by name (-lz).
# On Linux the conda toolchain reads only its own sysroot, so the linker finds no libz.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_link_libraries(sample_tool_lib PUBLIC z)'
