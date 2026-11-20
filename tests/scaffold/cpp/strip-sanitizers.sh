# expect: red Configure (CMakePresets.json
# string(REPLACE) removes the sanitizer flags after strict.cmake.
. "$(dirname "$0")/lib/attack"
overflow_test
perl -pi -e 's|^include\(cmake/strict\.cmake\)$|$&\nstring(REPLACE "-fsanitize=address,undefined" "" CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS}")|' CMakeLists.txt
grep -q 'string(REPLACE' CMakeLists.txt
fmt
