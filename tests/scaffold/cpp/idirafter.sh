# expect: red Configure (CMakePresets.json
# A project folder added with -idirafter, which clang treats as system headers.
. "$(dirname "$0")/lib/attack"
mkdir -p vendor
cat >vendor/vendor.hpp <<'H'
// Vendored helper.
#pragma once

// Reads the low bits.
inline int vendor_cast(int value) {
  long wide = value;
  const auto add = [wide](int value) { return static_cast<int>(wide) + value; };
  return add(*reinterpret_cast<int *>(&wide));
}
H
add_extra <<'C'
#include "extra.hpp"

#include <vendor.hpp>

namespace sample_tool {

int extra(int value) { return vendor_cast(value); }

} // namespace sample_tool
C
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_compile_options(sample_tool_lib PRIVATE "-idirafter${CMAKE_SOURCE_DIR}/vendor")'
fmt
