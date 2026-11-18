# expect: red Every project file is compiled
# A header in a git-ignored folder, which project_files skips, with NOLINT.
. "$(dirname "$0")/lib/attack"
printf 'build-extra/\n' >>.gitignore
mkdir -p build-extra
printf '// x\n#pragma once\ninline int vcast(long w) { return *reinterpret_cast<int *>(&w); } // NOLINT\n' >build-extra/v.hpp
add_extra <<'C'
#include "extra.hpp"

#include "../build-extra/v.hpp"

namespace sample_tool {

int extra(int value) { return vcast(value); }

} // namespace sample_tool
C
fmt
