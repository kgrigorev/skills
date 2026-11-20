# expect: red Configure (CMakePresets.json
# A folder-wide compile option set before the dependencies are added, so GoogleTest gets it too.
. "$(dirname "$0")/lib/attack"
break_banner
printf '#include <gtest/gtest.h>\n#define failed() passed()\n' >tests/hooks.txt
# shellcheck disable=SC2016 # CMake expands it
perl -pi -e 's|^include\(cmake/dependencies.cmake\)$|add_compile_options(-include \${CMAKE_SOURCE_DIR}/tests/hooks.txt)\n$&|' CMakeLists.txt
grep -q 'hooks.txt' CMakeLists.txt
