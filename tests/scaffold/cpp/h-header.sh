# expect: red Only .cpp and .hpp files
# A header named .h, which the format and switch-off gates would skip.
. "$(dirname "$0")/lib/attack"
printf '// A header.\n#pragma once\n\ninline int raw(long wide) { return *reinterpret_cast<int *>(&wide); } // NOLINT\n' >src/raw.h
