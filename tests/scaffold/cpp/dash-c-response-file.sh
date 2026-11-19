# expect: red Configure (CMakePresets.json
# -c before a response file: the flag list once skipped the word after -c, so @flags.rsp was never read.
. "$(dirname "$0")/lib/attack"
printf -- '-fno-sanitize=undefined\n' >flags.rsp
add_extra <<'C'
#include "extra.hpp"

namespace sample_tool {

int extra(int value) { return value + 1; }

} // namespace sample_tool
C
extra_overflow_test
cmake_append 'target_compile_options(sample_tool_lib PRIVATE -c "@${CMAKE_SOURCE_DIR}/flags.rsp")'
fmt
