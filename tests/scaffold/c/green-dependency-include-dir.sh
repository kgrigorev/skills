# expect: green
# A dependency's headers outside the repository, declared in CMake as an include folder. That is
# a change review sees, so the check accepts headers from it.
dep=$(cd .. && pwd -P)/sample-dep-include
mkdir -p "$dep"
cat >"$dep/sample_dep.h" <<'X'
#pragma once

static inline int sample_dep_twice(int value) { return value * 2; }
X
printf 'target_include_directories(sample_tool PRIVATE "%s")\n' "$dep" >>CMakeLists.txt
perl -0pi -e 's/(#include <string\.h>\n)/$1\n#include "sample_dep.h"\n/' src/sample_tool.c
cat >>src/sample_tool.c <<'X'

int sample_tool_twice(int value) { return sample_dep_twice(value); }
X
perl -0pi -e 's/(\n#endif)/\n\/\/\/ Twice `value`.\n[[nodiscard]] int sample_tool_twice(int value);\n$1/' include/sample_tool.h
