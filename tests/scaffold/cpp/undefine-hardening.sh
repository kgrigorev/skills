# expect: red Configure (CMakePresets.json
# The hardening macros undefined with -U for the tests.
. "$(dirname "$0")/lib/attack"
out_of_bounds_test
fmt
cmake_append 'target_compile_options(sample_tool_test PRIVATE -U_LIBCPP_HARDENING_MODE -U_GLIBCXX_ASSERTIONS)'
