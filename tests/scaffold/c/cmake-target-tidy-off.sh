# expect: red No switched-off checks
# clang-tidy turned off for one target.
printf 'set_target_properties(sample_tool PROPERTIES C_CLANG_TIDY "")\n' >>CMakeLists.txt
