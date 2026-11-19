# expect: red Test (sanitizers on
# A CTestCustom.cmake put by hand into the git-ignored build folder, with CTEST_CUSTOM_TESTS_IGNORE, which both ctest runs read. The check deletes it, so the failing test runs.
. "$(dirname "$0")/lib/attack"
break_banner
mkdir -p build/dev
printf 'set(CTEST_CUSTOM_TESTS_IGNORE Banner.NamesTheProgram)\n' >build/dev/CTestCustom.cmake
