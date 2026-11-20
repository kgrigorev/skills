# expect: red Every project file is built with the gates
# A compile definition for Unity itself, which is built without the gates and decides what passes.
printf 'target_compile_definitions(unity PRIVATE UNITY_OUTPUT_COLOR)\n' >>CMakeLists.txt
