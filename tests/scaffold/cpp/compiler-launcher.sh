# expect: red Configure (CMakePresets.json
# A compiler launcher that skips the compiler.
. "$(dirname "$0")/lib/attack"
printf '#!/bin/sh\nexit 0\n' >fakecc.sh
chmod +x fakecc.sh
perl -pi -e 's|^include\(cmake/strict\.cmake\)$|$&\nset(CMAKE_CXX_COMPILER_LAUNCHER \${CMAKE_SOURCE_DIR}/fakecc.sh)|' CMakeLists.txt
grep -q LAUNCHER CMakeLists.txt
