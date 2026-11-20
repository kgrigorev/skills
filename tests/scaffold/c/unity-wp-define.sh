# expect: red Every project file is built with the gates
# unity-compile-definition, spelled -Wp,-D and --define-macro.
printf 'set(gates_what options)\ncmake_language(CALL target_compile_${gates_what} unity PRIVATE -Wp,-DUNITY_OUTPUT_COLOR --define-macro=UNITY_EXCLUDE_DETAILS)\n' >>CMakeLists.txt
