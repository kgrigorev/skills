# expect: red No switched-off checks
# A warning turned off for one target.
printf 'target_compile_options(sample_tool PRIVATE -Wno-conversion)\n' >>CMakeLists.txt
