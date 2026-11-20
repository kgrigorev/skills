# expect: green
# A CTestTestfile.cmake left in the build folder by a removed subfolder, which ctest no longer reads.
. "$(dirname "$0")/lib/attack"
mkdir -p build/dev/old-folder
printf 'include("/nowhere/late.cmake")\n' >build/dev/old-folder/CTestTestfile.cmake
