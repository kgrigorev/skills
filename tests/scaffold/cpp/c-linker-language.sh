# expect: red Configure (CMakePresets.json
# C enabled and the test linked as C, whose link rule the checks did not read.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's/LANGUAGES CXX\)/LANGUAGES CXX C)/' CMakeLists.txt
grep -q 'LANGUAGES CXX C' CMakeLists.txt
cmake_append 'set_target_properties(sample_tool_test PROPERTIES LINKER_LANGUAGE C)'
