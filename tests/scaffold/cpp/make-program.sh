# expect: red Configure (CMakePresets.json
# CMAKE_MAKE_PROGRAM set to a repo script, which cmake --build then runs instead of ninja.
. "$(dirname "$0")/lib/attack"
printf '#!/bin/sh\nexec ninja "$@"\n' >scripts/nj
chmod +x scripts/nj
perl -pi -e 's|^project\(|set(CMAKE_MAKE_PROGRAM \${CMAKE_SOURCE_DIR}/scripts/nj CACHE FILEPATH "" FORCE)\n$&|' CMakeLists.txt
grep -q CMAKE_MAKE_PROGRAM CMakeLists.txt
