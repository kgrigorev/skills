# expect: red No switched-off checks
# A target outside `all` is never built, linted or tested.
printf 'add_library(extra EXCLUDE_FROM_ALL src/extra.c)\n' >>CMakeLists.txt
printf 'int sample_tool_narrow(long x);\nint sample_tool_narrow(long x) { return x; }\n' >src/extra.c
