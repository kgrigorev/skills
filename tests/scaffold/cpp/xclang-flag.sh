# expect: red Configure (CMakePresets.json
# A cc1 flag passed with -Xclang.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_compile_options(sample_tool_lib PRIVATE -Xclang -fno-sanitize-address-use-after-scope)'
