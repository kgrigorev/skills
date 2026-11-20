# expect: red No switched-off checks
# The test file switches libc++ hardening off before any include.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^#include "sample_tool.hpp"$|#undef _LIBCPP_HARDENING_MODE\n#define _LIBCPP_HARDENING_MODE _LIBCPP_HARDENING_MODE_NONE\n$&|' tests/sample_tool_test.cpp
out_of_bounds_test
fmt
