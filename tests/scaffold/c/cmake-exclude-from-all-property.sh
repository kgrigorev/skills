# expect: red No switched-off checks
# The same, through set_target_properties.
printf 'add_library(extra src/extra.c)\nset_target_properties(extra PROPERTIES EXCLUDE_FROM_ALL ON)\n' >>CMakeLists.txt
printf 'int sample_tool_narrow(long x);\nint sample_tool_narrow(long x) { return x; }\n' >src/extra.c
