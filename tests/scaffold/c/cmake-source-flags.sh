# expect: red No switched-off checks
# Flags set on one source file.
printf 'set_source_files_properties(src/sample_tool.c PROPERTIES COMPILE_OPTIONS -w)\n' >>CMakeLists.txt
