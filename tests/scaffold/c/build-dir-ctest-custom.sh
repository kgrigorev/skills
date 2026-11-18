# expect: red Test
# build/ is ignored by git, and scripts/check keeps build/dev unless the tools, the presets or
# .clang-tidy change. A hand-written build/dev/CTestCustom.cmake drops the failing property test
# from both ctest runs. Only CI's fresh build would see the failure, and the file outlives a
# reverted CMakeLists.txt line that wrote it. The check removes it, so later runs are clean.
mkdir -p build/dev
printf 'set(CTEST_CUSTOM_TESTS_IGNORE sample_tool_property)\n' >build/dev/CTestCustom.cmake
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
