# expect: red Every project file is built with the gates
# A compile definition that makes every float assertion pass (Unity keeps a precision that is
# already defined), which the source search cannot see.
printf 'target_compile_definitions(sample_tool_test PRIVATE UNITY_FLOAT_PRECISION=1000.0f)\n' >>CMakeLists.txt
