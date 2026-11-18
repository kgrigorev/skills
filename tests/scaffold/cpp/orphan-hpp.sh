# expect: red Every project file is compiled
# A header that nothing includes, with a C-style cast. Nothing would lint it.
. "$(dirname "$0")/lib/attack"
printf '// Orphan header.\n#pragma once\n\n// Casts.\ninline int orphan(int value) {\n  long wide = value;\n  return *(int *)(&wide);\n}\n' >src/orphan.hpp
fmt
