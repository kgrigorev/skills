# expect: red Configure (CMakePresets.json
# A @response file that passes -Wno-shadow-all.
. "$(dirname "$0")/lib/attack"
shadow_body | add_extra
printf -- '-Wno-shadow-all\n' >flags.rsp
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(sample_tool_lib PRIVATE "@${CMAKE_SOURCE_DIR}/flags.rsp")'
fmt
