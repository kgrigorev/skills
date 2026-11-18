# expect: red Configure (CMakePresets.json
# A --config= file that passes -Wno-shadow-all.
. "$(dirname "$0")/lib/attack"
shadow_body | add_extra
printf -- '-Wno-shadow-all\n' >flags.cfg
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(sample_tool_lib PRIVATE "--config=${CMAKE_SOURCE_DIR}/flags.cfg")'
fmt
