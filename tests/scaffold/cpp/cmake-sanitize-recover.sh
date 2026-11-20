# expect: red Configure (CMakePresets.json
# target_compile_options with -fsanitize-recover=all, so UBSan reports and goes on.
. "$(dirname "$0")/lib/attack"
overflow_test
cmake_append 'target_compile_options(sample_tool_test PRIVATE -fsanitize-recover=all)'
fmt
