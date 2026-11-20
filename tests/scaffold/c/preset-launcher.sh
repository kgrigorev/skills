# expect: red Every project file is built with the gates
# A compiler launcher in the dev preset, which could drop any flag.
perl -pi -e 's|"GATES_CLANG_TIDY": "clang-tidy"|"GATES_CLANG_TIDY": "clang-tidy",\n        "CMAKE_C_COMPILER_LAUNCHER": "env"|' CMakePresets.json
