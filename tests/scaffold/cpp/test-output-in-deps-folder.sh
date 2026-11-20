# expect: red Every project file is compiled
# The test executable written into GoogleTest's build folder, which once made the check treat it as GoogleTest and skip its link flags.
. "$(dirname "$0")/lib/attack"
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'set_target_properties(sample_tool_test PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/_deps/googletest-build)'
cmake_append 'target_link_options(sample_tool_test PRIVATE -rdynamic)'
