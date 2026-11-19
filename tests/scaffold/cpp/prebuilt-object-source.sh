# expect: red Configure (CMakePresets.json
# A prebuilt object in the ignored build folder, listed as a source, which links code no gate read (such as a no-op sanitizer handler).
. "$(dirname "$0")/lib/attack"
mkdir -p build/dev
printf 'not really an object\n' >build/dev/hook.o
perl -pi -e 's|^add_executable\(sample_tool_test tests/sample_tool_test\.cpp|$& \${CMAKE_BINARY_DIR}/hook.o|' CMakeLists.txt
grep -q 'hook.o' CMakeLists.txt
