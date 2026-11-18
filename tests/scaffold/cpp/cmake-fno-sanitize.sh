# expect: red No switched-off checks
# target_compile_options with -fno-sanitize=undefined.
. "$(dirname "$0")/lib/attack"
overflow_test
cmake_append 'target_compile_options(sample_tool_test PRIVATE -fno-sanitize=undefined)'
fmt
