# expect: green
# include(CTest), the usual way to turn testing on.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's/^enable_testing\(\)$/include(CTest)/' CMakeLists.txt
grep -q 'include(CTest)' CMakeLists.txt
