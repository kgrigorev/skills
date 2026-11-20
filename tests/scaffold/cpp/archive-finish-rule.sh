# expect: red Configure (CMakePresets.json
# CMAKE_CXX_ARCHIVE_FINISH runs a repo script on each static library, which could swap in an object built without sanitizers.
. "$(dirname "$0")/lib/attack"
printf '#!/bin/sh\ntrue\n' >scripts/finish
chmod +x scripts/finish
perl -pi -e 's|^add_library\(sample_tool_lib|set(CMAKE_CXX_ARCHIVE_FINISH "<CMAKE_RANLIB> <TARGET> \&\& sh \${CMAKE_SOURCE_DIR}/scripts/finish <TARGET>")\n$&|' CMakeLists.txt
grep -q ARCHIVE_FINISH CMakeLists.txt
