# expect: red No switched-off checks
# A CMakeLists.txt in a subfolder is searched too.
printf 'add_subdirectory(src/extra)\n' >>CMakeLists.txt
mkdir -p src/extra
printf 'add_library(extra extra.c)\ntarget_compile_options(extra PRIVATE -w)\n' >src/extra/CMakeLists.txt
printf 'int sample_tool_narrow(long x);\nint sample_tool_narrow(long x) { return x; }\n' >src/extra/extra.c
