# expect: red Only .cpp and .hpp files
# A project header in src/_deps/, which .clang-tidy would skip as a dependency.
. "$(dirname "$0")/lib/attack"
mkdir -p src/_deps
printf '// Casts.\n#pragma once\n\n// Reads the low bits.\ninline int vcast(long wide) { return *reinterpret_cast<int *>(&wide); }\n' >src/_deps/v.hpp
add_extra <<'C'
#include "extra.hpp"

#include "_deps/v.hpp"

namespace sample_tool {

int extra(int value) { return vcast(value); }

} // namespace sample_tool
C
fmt
