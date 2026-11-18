# expect: red No switched-off checks
# A test marked DISABLED through the generic property command.
printf 'set_property(TEST sample_tool_property PROPERTY DISABLED ON)\n' >>CMakeLists.txt
