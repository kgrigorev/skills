# expect: green
# Plain comments in CMakeLists.txt that use the words "disabled" and "add_test".
perl -0pi -e 's/(option\(BUILD_TESTING)/# The release preset builds with tests disabled.\n# Tests are registered with add_unity_test and add_property_test below, never add_test.\n$1/' CMakeLists.txt
grep -q 'tests disabled' CMakeLists.txt
