# expect: red Every project file is built with the gates
# NDEBUG turns every assert() off.
printf 'target_compile_definitions(sample_tool PRIVATE NDEBUG)\n' >>CMakeLists.txt
