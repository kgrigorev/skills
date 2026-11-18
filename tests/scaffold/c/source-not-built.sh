# expect: red Every project file is built with the gates
# A .c file that no target builds is never compiled, linted or tested.
printf 'int sample_tool_narrow(long x);\nint sample_tool_narrow(long x) { return x; }\n' >src/orphan.c
