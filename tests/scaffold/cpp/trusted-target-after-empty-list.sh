# expect: red Configure (CMakePresets.json
# expect-output: changes the target gtest
# An empty list variable before the target name, which CMake drops but the trace shows as an argument.
. "$(dirname "$0")/lib/attack"
cmake_append 'set(none "")'
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(${none} gtest PRIVATE -DSAMPLE=1)'
