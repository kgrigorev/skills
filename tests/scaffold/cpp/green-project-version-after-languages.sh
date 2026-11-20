# expect: green
# project() with VERSION after LANGUAGES, which CMake accepts.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's/^project\(sample_tool VERSION 0\.1\.0 LANGUAGES CXX\)$/project(sample_tool LANGUAGES CXX VERSION 0.1.0)/' CMakeLists.txt
grep -q 'LANGUAGES CXX VERSION' CMakeLists.txt
